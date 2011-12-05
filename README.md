# Zencodable

Gives you `has_video_encodings` method for your models, that sets up jobs to encode multiple video container/codecs using [Zencoder](http://zencoder.com). It tells Zencoder to place the output files in some bucket in your S3 account. From there, they are yours to enjoy forever.

```ruby
class Video < ActiveRecord::Base

  has_video_encodings :video_files, :formats            => [:ogg, :mp4, :webm, :flv],
                                    :output_dimensions  => '852x480',
                                    :s3_config          => "#{Rails.root}/config/amazon_s3.yml",
                                    :path               => "videos/zc/:basename/",
                                    :thumbnails         => { :number => 2, :aspect_mode => 'crop', 'size' => '290x160' },
                                    :options            => { :device_profile => 'mobile/advanced' }

end
```

## Requirements

_developed on ruby 1.9.2-p290 and Rails 3.1.3_

1. A [Zencoder][1] account of course, testing or full.

2. A working Amazon S3 account with a shiny new bucket ready to receive video files.

3. this gem (zencodable) in your gemfile, and typhoeus.

    gem 'zencodable'
    gem 'typhoeus' # NOTE: for heroku deploys, pin to 0.2.4 https://github.com/dbalatero/typhoeus/issues/123

# Setup

## Zencoder API keys and initializer settings

the [zencoder](https://github.com/zencoder/zencoder-rb) gem expects access to your Zencoder API keys in some fashion. Also, [typhoeus](https://github.com/dbalatero/typhoeus) is a big improvement for HTTP stuffs. Thirdly, Zencoder's API v2 (soon to be released as of 2011-12-4) is full of options, has more progress information and much more hotness - so let's use that!.

So, I like something in `config/initializers/zencoder.rb` like

    # zencoder setup
    if Rails.env == 'production'
      Zencoder.api_key = 'therealdealkey00000000000000000'
    else
      Zencoder.api_key = 'keyfortestingonly00000000000000'
    end

    Zencoder::HTTP.http_backend = Zencoder::HTTP::Typhoeus

    Zencoder.base_url = 'https://app.zencoder.com/api/v2'

## Bucket policy

The bucket needs to have a custom policy to allow Zencoder to place the output videos on it. [Here is a guide on Zencoder's site, follow it](https://app.zencoder.com/docs/guides/getting-started/working-with-s3)

(There is currently a branch where an attempt to create a rake task to auto-install this policy was made. Unfortunately it seems the marcel/aws-s3 gem doesn't know how to update a bucket policy after all, it just manages the ACLs. It seems fog can't do that either. Oh well, you'll have to paste in the policy.)

## Run the generator

    rails g zencodable:migrations <Model> <association_name>

e.g.,

    rails g zencodable:migrations KittehVideo kitteh_video_files

This will actually create two `has_many` associations for your model - the `kitteh_video_files` for the output files themselves (one for each format), and the `kitteh_video_file_thumbnails` for the framegrab thumbnails that Zencoder can create (if configured).

you can add a `--skip-thumbnails` option if you don't want to use the auto-generated thumbnails.

now do a `rake db:migrate`

## How to use

### Configure model and encoding options

add something like the above `has_video_encodings` class method to your model (the generator does not try to do this for you).

The options should include a `:s3_config` key that gives a location of a YAML file containing your S3 credentials, which should contain a 'bucket' key (you already have one, right?) Actually, all we need from that is the bucket name, so you can instead use a `:bucket` key to give the name of the bucket where the output files should be placed.

The `:path` option can be any path within that bucket. It can contain a `:basename` token, which will be replaced with a sanitized, URL-encoded version of the original filename as uploaded.

`:formats` is a list of output formats you'd like. [Supported formats and codecs](https://app.zencoder.com/docs/api/encoding/format-and-codecs/format)

The other options are all those that can be handled by Zencoder. More info can be found on [:thumbnails](https://app.zencoder.com/docs/api/encoding/thumbnails), [:output_dimensions](https://app.zencoder.com/docs/api/encoding/resolution/size) and other output settings [:options](https://app.zencoder.com/docs/api/encoding)

### Give it a source URL

All that's needed to trigger the Zencoder job is to change the `origin_url` value of your model, and then save. That will be picked up, sent to Zencoder, and your job will be started with your desired settings.

As the job runs, you can check `Model.job_status` as you see fit, if the job is neither failed nor finished, it will request an update from Zencoder for that Job.

Individual files will complete at different times, so you can also check the `state` of each associated output file.

    vid = Video.new :title => 'Hilarious Kitteh Antics!'
    vid.origin_url = 'http://sourcebucket.s3.amazonaws.com/largevideos/funny_kittehs[HD].mov'
    vid.save
    vid.job_status # "new"
    ...
    vid.job_status # "waiting"
    ...
    vid.job_status # "processing"
    vid.video_encoded_files.collect { |v| [v.format, v.state] }
    ...
    vid.job_status # "finished"
    vid.video_encoded_files.size # 4
    vid.video_encoded_file_thumbnails.size # 2


## TODO

* rake task to generate a working bucket policy (even if it has to be pasted in)
* set timeouts on update_job
* create DJ and/or Resque workers to handle job submission (should be optional dependencies though)
* generator to install config/initializer
* remove files from S3 when object is deleted
* background jobs to update the ZC job progress, with events/notifications
* use API v2 features to get more interesting info on job progress
* is s3_url basename sanitization going to be good for non-ASCII filenames? no.

## License

Uses MIT-LICENSE. You are free to use this as you like, but don't expect anything.

Forking and pull requests would be much appreciated.

  [1]:http://zencoder.com/

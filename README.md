rails-lighthouse-archive
========================

In April 2011, the [Rails project][1] moved its issue tracking from [Lighthouse][2] to [GitHub Issues][3]. Initially, public access to the Lighthouse project was switched off entirely, provoking some negative reaction [on the mailing list][4] and [on the new issue tracker][5].

As of 6 May 2011, the Lighthouse issue tracker has been reopened temporarily, to allow porting of open tickets across to the new issue tracker. It is not clear what the long-term plan for the Lighthouse project is.

There is a lot of useful history in the Lighthouse issue tracker. On the assumption that public access to it will be turned off again, this project is an attempt to archive that data publicly.

Status
------

At the moment, this is just some hacky, quickly-written scripts to grab the raw data from the Lighthouse project, via the Lighthouse API.

The resulting individual XML files, and the 'attachments' (files uploaded to the issue tracker; mostly patch files), are in the 'data' directory.

To-do
-----

The rough plan is to use the XML data to generate a static HTML version of the issues as they existed when the data was grabbed.

License
-------

The programs ending in ".rb" in the root directory of this repository are copyright 2011 Chris Mear <chris@feedmechocolate.com>, and are licensed to the public under the MIT License.

[1]: http://www.rubyonrails.org/
[2]: https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/overview
[3]: https://github.com/rails/rails/issues
[4]: https://groups.google.com/d/topic/rubyonrails-core/ElxiZHaU07c/discussion
[5]: https://github.com/rails/rails/issues/404

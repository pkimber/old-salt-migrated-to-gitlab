# -*- encoding: utf-8 -*-
{% set env = settings.get('env', {}) -%}
"""
Watch a folder.  Upload new files to Alfresco.

Changelog
=========

2017
----

We are not using FTP upload for Django templates, so I am updating the script
to copy files to an Alfresco server.

We were using watchdog (see code from 2014), but watchdog does not know when a
file has finished copying.  I have searched for ideas, and it seems most of
them are flawed.  People suggest watching the file size - when the file size
stops increasing, then the file has finished copying.  This doesn't feel safe
to me.  ``inotify`` seems a more elegant solution, but apparently, some file
copy operations send multiple ``CLOSE_WRITE`` events.

I am now attempting to use ``inotify``, but all python ``inotify`` packages are
complicated.  ``inotify-simple`` is simple to use, so I will try it.

.. warning:: This code will not work on Windows because it doesn't have
             ``inotify``.

Sample code copied from:
http://inotify-simple.readthedocs.io/en/latest/

2014
----

Code was used to set permissions on files after upload by an FTP server.  I
think the files were Django templates which could be incorporated into the
site.

Original code copied from:
http://brunorocha.org/python/watching-a-directory-for-file-changes-with-python.html

"""
import json
import os
import requests
import stat
import sys
import time
import urllib.parse

from inotify_simple import INotify, flags, masks


class MyHandler:

    def _chown(self, src_path):
        if os.path.isfile(src_path):
            sys.stdout.write('is_file: {}'.format(src_path))
            try:
                os.chmod(
                    src_path,
                    stat.S_IREAD | stat.S_IWRITE | stat.S_IRGRP | stat.S_IROTH
                )
            except OSError as e:
                sys.stdout.write(e)
        else:
            sys.stdout.write('is_directory: {}'.format(src_path))
            try:
                os.chmod(
                    src_path,
                    stat.S_IREAD | stat.S_IWRITE | stat.S_IEXEC | stat.S_IRGRP | stat.S_IXGRP | stat.S_IROTH | stat.S_IXOTH
                )
            except OSError as e:
                sys.stdout.write(e)

    def _response(self, r):
        sys.stdout.write('status_code: {}'.format(r.status_code))
        sys.stdout.write('content-type: {}'.format(r.headers['content-type']))
        sys.stdout.write('json: {}'.format(json.dumps(r.json(), indent=4)))

    def _url(self, path=None):
        query_path = '/'.join(['alfresco', 'api'])
        if path:
            query_path = '/'.join([query_path, path])
        result = urllib.parse.urljoin('{{ env['alfresco_url'] }}', query_path)
        sys.stdout.write('url: {}'.format(result))
        return result

    def on_created(self, src_path):
        auth = (
            "{{ env['alfresco_user'] }}",
            "{{ env['alfresco_pass'] }}",
        )
        # change the owner
        self._chown(src_path)
        # upload to alfresco
        if os.path.isfile(src_path):
            # upload a file
            sys.stdout.write("Found '{}'".format(src_path))
            url = self._url(
                '-default-/public/alfresco/versions/1/nodes/-my-/children'
            )
            files = {'filedata': open(src_path, 'rb')}
            r = requests.post(url, auth=auth, files=files)
            self._response(r)
            sys.stdout.write(
                "Uploaded '{}' to Alfresco".format(src_path)
            )


if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else '.'
    inotify = INotify()
    watch_flags = flags.CLOSE_WRITE
    sys.stdout.write('watching: {}'.format(path))
    wd = inotify.add_watch(path, watch_flags)
    while True:
        for event in inotify.read():
            for flag in flags.from_mask(event.mask):
                if flag == flags.CLOSE_WRITE:
                    file_path = os.path.join(path, event.name)
                    sys.stdout.write('CLOSE_WRITE: {}'.format(file_path))
                    handler = MyHandler()
                    handler.on_created(file_path)

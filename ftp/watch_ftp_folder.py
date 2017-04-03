# -*- encoding: utf-8 -*-
{% set env = settings.get('env', {}) -%}
"""
Sample copied from:
http://brunorocha.org/python/watching-a-directory-for-file-changes-with-python.html
"""
import json
import os
import requests
import stat
import sys
import time
import urllib.parse

from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer


class MyHandler(FileSystemEventHandler):

    def _chown(self, event):
        is_file = False
        if event.is_directory:
            sys.stdout.write('is_directory: {}'.format(event.src_path))
            try:
                os.chmod(
                    event.src_path,
                    stat.S_IREAD | stat.S_IWRITE | stat.S_IEXEC | stat.S_IRGRP | stat.S_IXGRP | stat.S_IROTH | stat.S_IXOTH
                )
            except OSError as e:
                sys.stdout.write(e)
                pass
        else:
            sys.stdout.write('NOT event.is_directory: {}'.format(event.src_path))
            try:
                os.chmod(
                    event.src_path,
                    stat.S_IREAD | stat.S_IWRITE | stat.S_IRGRP | stat.S_IROTH
                )
                is_file = True
            except OSError as e:
                sys.stdout.write(e)
                pass
        return is_file

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

    def on_created(self, event):
        auth = (
            "{{ env['alfresco_user'] }}",
            "{{ env['alfresco_pass'] }}",
        )
        # change the owner
        is_file = self._chown(event)
        # upload to alfresco
        if is_file:
            # upload a file
            sys.stdout.write("Found '{}'".format(event))
            url = self._url(
                '-default-/public/alfresco/versions/1/nodes/-my-/children'
            )
            files = {'filedata': open(event.src_path, 'rb')}
            r = requests.post(url, auth=auth, files=files)
            self._response(r)
            sys.stdout.write(
                "Uploaded '{}' to Alfresco".format(event.src_path)
            )


if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else '.'
    event_handler = MyHandler()
    observer = Observer()
    observer.schedule(event_handler, path, recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()

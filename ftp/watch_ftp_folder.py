# -*- encoding: utf-8 -*-
"""
Sample copied from:
http://brunorocha.org/python/watching-a-directory-for-file-changes-with-python.html
"""
import os
import stat
import sys
import time
import json
import os
import requests
import urllib.parse


from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


class MyHandler(FileSystemEventHandler):

    def _chown(self, event):
        is_file = False
        if event.is_directory:
            print('is_directory: {}'.format(event.src_path))
            try:
                os.chmod(event.src_path, stat.S_IREAD | stat.S_IWRITE | stat.S_IEXEC | stat.S_IRGRP | stat.S_IXGRP | stat.S_IROTH | stat.S_IXOTH)
            except OSError as e:
                print(e)
                pass
        else:
            print('NOT event.is_directory: {}'.format(event.src_path))
            try:
                os.chmod(event.src_path, stat.S_IREAD | stat.S_IWRITE | stat.S_IRGRP | stat.S_IROTH)
                is_file = True
            except OSError as e:
                print(e)
                pass
        return is_file

    def _response(self, r):
        print('status_code: {}'.format(r.status_code))
        print('content-type: {}'.format(r.headers['content-type']))
        print('json: {}'.format(json.dumps(r.json(), indent=4)))

    def _url(self, path=None):
        query_path = '/'.join(['alfresco', 'api'])
        if path:
            query_path = '/'.join([query_path, path])
        result = urllib.parse.urljoin({{ env['alfresco_url'] }}, query_path)
        print('url: {}'.format(result))
        return result

    def on_created(self, event):
        # change the owner
        is_file = self._chown(event)
        # upload to alfresco
        if is_file:
            # discovery
            # url = self._url('discovery')
            # r = requests.get(
            #     url,
            #     auth=({{ env['alfresco_user'] }}, {{ env['alfresco_pass'] }}),
            # )
            # self._response(r)
            # upload a file
            print("Found '{}'".format(event))
            url = self._url(
                '-default-/public/alfresco/versions/1/nodes/-my-/children'
            )
            # file_path = os.path.join(
            #     os.path.dirname(os.path.realpath(__file__)),
            #     'honeydown.pdf',
            # )
            # files = {'filedata': open(file_path, 'rb')}
            files = {'filedata': open(event, 'rb')}
            r = requests.post(
                url,
                auth=({{ env['alfresco_user'] }}, {{ env['alfresco_pass'] }}),
                files=files,
            )
            self._response(r)
            print("Uploaded '{}' to Alfresco".format(event))
            self.stdout.write("Complete...")


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

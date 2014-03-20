"""
Sample copied from:
http://brunorocha.org/python/watching-a-directory-for-file-changes-with-python.html
"""
import os
import stat
import sys
import time

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


class MyHandler(FileSystemEventHandler):

    def _chown(self, event):
        if event.is_directory:
            print 'is_directory: {}'.format(event.src_path)
            os.chmod(event.src_path, stat.S_IREAD | stat.S_IWRITE | stat.S_IEXEC | stat.S_IRGRP | stat.S_IXGRP | stat.S_IROTH | stat.S_IXOTH)
        else:
            print 'NOT event.is_directory: {}'.format(event.src_path)
            os.chmod(event.src_path, stat.S_IREAD | stat.S_IWRITE | stat.S_IRGRP | stat.S_IROTH)

    def on_created(self, event):
        self._chown(event)


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

python3 uwsgiconfig.py --build core && \
    python3 uwsgiconfig.py --plugin plugins/http core && \
    python3 uwsgiconfig.py --plugin plugins/corerouter core && \
    python3 uwsgiconfig.py --plugin plugins/python core && \
    python3 uwsgiconfig.py --plugin plugins/stats_pusher_statsd core

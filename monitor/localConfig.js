{
    graphitePort: 2003,
    graphiteHost: "{{ django['monitor'] }}",
    port: 8125,
    backends: [ "./backends/graphite" ]
}

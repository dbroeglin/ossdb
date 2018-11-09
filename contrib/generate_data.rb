SIZE = 25


#open('Sources/Nodes/nodes.csv', 'w') { |f|
#    f.puts "name,memory,cores"
#    f.puts "jeexxx01,2048,4"
#    f.puts "jeexxx02,2048,4"
#    f.puts "jeexxx03,2048,4"
#    f.puts "jeexxx04,2048,4"
#    SIZE.times { |i|
#        j = i * 4
#        f.puts "jeetest%04d,4092,2" % j
#        f.puts "jeetest%04d,4092,2" % (j + 1)
#        f.puts "jeetest%04d,8192,8" % (j + 2)
#        f.puts "jeetest%04d,8192,8" % (j + 3)
#    }
#}

open('Sources/Nodes/node_ips.csv', 'w') { |f|
    f.puts "Hostname,IP"
    f.puts "jeexxx01,10.0.3.0"
    f.puts "jeexxx02,10.0.3.1"
    f.puts "jeexxx03,10.0.3.2"
    f.puts "jeexxx04,10.0.3.3"
    f.puts "jeexxx04,10.0.4.1"
    f.puts "jeexxx04,10.0.4.2"
    f.puts "jeexxx04,10.0.4.3"
    SIZE.times { |i|
        j = i * 4
        f.puts "jeetest%04d,10.0.1.%d" % [j, i]
        f.puts "jeetest%04d,10.0.2.%d" % [j + 1, i]
        f.puts "jeetest%04d,10.100.10.%d" % [j + 2, i]
        f.puts "jeetest%04d,10.100.11.%d" % [j + 3, i]
    }
}

open('Sources/DNS/dns_records.csv', 'w') { |f|
    f.puts "zoneName,recName,recType,recValue"
    f.puts "foo.com,www,A,100.0.3.0"
    f.puts "bar.com,www,A,100.0.4.0"
    f.puts "bar.com,www,A,100.0.4.1"
    f.puts "foobar.com,www,CNAME,www.bar.com"
    
    # LLB addresses
    f.puts "acme.com,lla,A,100.100.0.1"
    f.puts "acme.com,llb,A,100.100.0.2"
    SIZE.times { |i|
        k = i * 2
        f.puts "foo%03d.com,www,NS,llba.acme.com" % [i, k]
        f.puts "foo%03d.com,www,NS,llbb.acme.com" % [i, k]
        f.puts "bar%03d.com,www,A,100.0.2.%d" % [i, k]
    }
}

open('Sources/LinkLoadBalancers/link_load_balancer.csv', 'w') { |f|
    f.puts "node,type,inRangeLow,inRangeHigh,routerIP,outRangeLow,outRangeHigh,FQDN"
    f.puts "llba,static,1.0.3.0,1.0.3.0,100.0.3.254,100.0.3.0,100.0.3.0,www.foo.com foo.com"
    f.puts "llba,static,1.0.4.0,1.0.4.0,100.0.4.254,100.0.4.0,100.0.4.0,www.bar.com bar.com old.bar.com"
    f.puts "lllb,static,1.0.3.0,1.0.3.0,100.0.3.254,100.0.3.0,100.0.3.0,www.foo.com foo.com"
    f.puts "llla,static,1.0.3.0,1.0.3.0,100.0.3.254,100.0.5.0,100.0.5.0," # empty FQDN
    # f.puts "llba,static,1.0.4.0,1.0.4.0,100.0.3.254,100.0.4.0,100.0.4.0,www.bar.com"
    SIZE.times { |i|
        f.puts "llba,static,1.0.3.%d,1.0.3.%d,100.0.3.254,100.0.3.%d,100.0.3.%d,www.foo%03d.com" % [i, i, i, i, i]
        f.puts "llbb,static,1.0.3.%d,1.0.3.%d,100.0.3.254,100.0.3.%d,100.0.3.%d,www.foo%03d.com" % [i, i, i, i, i]
        f.puts "llba,static,1.0.2.%d,1.0.2.%d,100.0.2.254,100.0.2.%d,100.0.2.%d,www.bar%03d.com" % [i, i, i, i, i]
        f.puts "llbb,static,1.0.2.%d,1.0.2.%d,100.0.2.254,100.0.2.%d,100.0.2.%d,www.bar%03d.com" % [i, i, i, i, i]
    }
}

open('Sources/LoadBalancers/load_balancers.csv', 'w') { |f|
    f.puts "Name,VIP,NatIP,BackendIP,BackendName,BackendDescription"
    f.puts "Foo,1.0.3.0,,10.0.3.0,primary,Foo primary"
    f.puts "Foo,1.0.3.0,,10.0.3.1,secondary,Foo secondary"
    f.puts "Foo,1.0.3.0,,10.0.3.2,ternary,Foo ternary"
    f.puts "Foo,1.0.3.0,,10.0.3.3,quaternary,Foo quarternary"
    SIZE.times { |i|
        k = i * 2
        f.puts "Foo %03d,1.0.3.%d,primary,10.0.1.%d" % [i, i, i]
        f.puts "Foo %03d,1.0.3.%d,secondary,10.0.2.%d" % [i, i, i]
        f.puts "Bar %03d,1.0.2.%d,primary,10.100.1.%d" % [i, i, i]
        f.puts "Bar %03d,1.0.2.%d,secondary,10.100.2.%d" % [i, i, i]
    }
}

open('Sources/Apache/apache_services.csv', 'w') { |f|
    f.puts "itEnv,name,service_description,hostname,service_ip,vhost_fqdn,vhost_aliases,worker,backend_hostname,backend_port"
    f.puts 'PRD,FOO,FOOCOM,apache1.local,10.0.3.0,www.foo.com,"foo.com,foo.io",WRK1,foo-a,8080'
    f.puts 'PRD,FOO,FOOCOM,apache2.local,10.0.3.1,www.foo.com,"foo.com,foo.io",WRK1,foo-b,8080'
    f.puts 'PRD,FOO,FOOCOM,apache3.local,10.0.3.2,www.foo.com,"foo.com,foo.io",WRK1,foo-c,8080'
    f.puts 'PRD,FOO,FOOCOM,apache3.local,10.0.3.2,www.foo.com,"foo.com,foo.io",WRK1,foo-d,8080'
    f.puts 'PRD,FOO,FOOCOM,apache4.local,10.0.3.3,www.foo.com,"foo.com,foo.io",WRK1,foo-e,8080'
    f.puts 'PRD,FOO,FOOCOM,apache4.local,10.0.3.3,www.foo.com,"foo.com,foo.io",WRK1,foo-f,8080'
    f.puts 'PRD,FOO,FOOCOM,apache4.local,10.0.3.3,www.foobar1.com,,,,'
    f.puts 'PRD,FOO,FOOCOM,apache4.local,10.0.3.3,www.foobar2.com,,ProxyPass,backend,80'
    SIZE.times { |i|
        f.puts 'PRD,FOO%d,FOOCOM %d,apache1.local,10.0.1.%d,www.foo%03d.com,,WRK1,foo-a,%d' % [i / 8, i, i, i, 8000 + i]
        f.puts 'PRD,FOO%d,FOOCOM %d,apache1.local,10.0.1.%d,www.foo%03d.com,,WRK1,foo-b,%d' % [i / 8, i, i, i, 8001 + i]
        f.puts 'PRD,FOO%d,FOOCOM %d,apache2.local,10.0.2.%d,www.foo%03d.com,,WRK1,foo-a,%d' % [i / 8, i, i, i, 8000 + i]
        f.puts 'PRD,FOO%d,FOOCOM %d,apache2.local,10.0.2.%d,www.foo%03d.com,,WRK1,foo-b,%d' % [i / 8, i, i, i, 8001 + i]
    }
}



SIZE = 25

open('Sources/Hosts/hosts.csv', 'w') { |f|
    f.puts "name,memory,cores"
    f.puts "jeexxx01,2048,4"
    f.puts "jeexxx02,2048,4"
    f.puts "jeexxx03,2048,4"
    f.puts "jeexxx04,2048,4"
    SIZE.times { |i|
        j = i * 4
        f.puts "jeetest%04d,4092,2" % j
        f.puts "jeetest%04d,4092,2" % (j + 1)
        f.puts "jeetest%04d,8192,8" % (j + 2)
        f.puts "jeetest%04d,8192,8" % (j + 3)
    }
}

open('Sources/Hosts/hosts_ips.csv', 'w') { |f|
    f.puts "name,ipv4Address"
    f.puts "jeexxx01,10.0.3.0"
    f.puts "jeexxx02,10.0.3.1"
    f.puts "jeexxx03,10.0.3.2"
    f.puts "jeexxx04,10.0.3.3"
    SIZE.times { |i|
        j = i * 4
        f.puts "jeetest%04d,10.0.1.%d" % [j, i]
        f.puts "jeetest%04d,10.0.2.%d" % [j + 1, i]
        f.puts "jeetest%04d,10.100.10.%d" % [j + 2, i]
        f.puts "jeetest%04d,10.100.11.%d" % [j + 3, i]
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

open('Sources/DNS/dns_records.csv', 'w') { |f|
    f.puts "zoneName,recName,recType,recValue"
    f.puts "foo.com,www,A,100.0.3.0"
    f.puts "bar.com,www,A,100.0.4.0"
    f.puts "foobar.com,www,CNAME,www.bar.com"
    SIZE.times { |i|
        k = i * 2
        f.puts "foo%03d.com,www,A,100.0.1.%d" % [i, k]
        f.puts "bar%03d.com,www,A,100.0.2.%d" % [i, k]
    }
}

open('Sources/LinkLoadBalancers/link_load_balancer.csv', 'w') { |f|
    f.puts "node,type,inRangeLow,inRangeHigh,routerIP,outRangeLow,outRangeHigh,FQDN"
    f.puts "llba,static,1.0.3.0,1.0.3.0,100.0.3.254,100.0.3.0,100.0.3.0,www.foo.com foo.com"
    f.puts "llba,static,1.0.4.0,1.0.4.0,100.0.4.254,100.0.4.0,100.0.4.0,www.bar.com bar.com"
    f.puts "lllb,static,1.0.3.0,1.0.3.0,100.0.3.254,100.0.3.0,100.0.3.0,www.foo.com foo.com"
    # f.puts "llba,static,1.0.4.0,1.0.4.0,100.0.3.254,100.0.4.0,100.0.4.0,www.bar.com"
    SIZE.times { |i|
        f.puts "llba,static,1.0.3.%d,1.0.3.%d,100.0.3.254,100.0.3.%d,100.0.3.%d,www.foo%03d.com" % [i, i, i, i, i]
        f.puts "llbb,static,1.0.3.%d,1.0.3.%d,100.0.3.254,100.0.3.%d,100.0.3.%d,www.foo%03d.com" % [i, i, i, i, i]
        f.puts "llba,static,1.0.2.%d,1.0.2.%d,100.0.2.254,100.0.2.%d,100.0.2.%d,www.bar%03d.com" % [i, i, i, i, i]
        f.puts "llbb,static,1.0.2.%d,1.0.2.%d,100.0.2.254,100.0.2.%d,100.0.2.%d,www.bar%03d.com" % [i, i, i, i, i]
    }
}

open('Sources/Apache/apache_services.csv', 'w') { |f|
    f.puts "fqdn,ipv4Address"
    f.puts "www.foo.com,10.0.3.0"
    f.puts "www.foo.com,10.0.3.1"
    f.puts "www.foo.com,10.0.3.2"
    f.puts "www.foo.com,10.0.3.3"
    SIZE.times { |i|
        f.puts "www.foo%03d.com,10.0.1.%d" % [i, i]
        f.puts "www.foo%03d.com,10.0.2.%d" % [i, i]
        
        f.puts "www.bar%03d.com,10.100.10.%d" % [i, i]
        f.puts "www.bar%03d.com,10.100.11.%d" % [i, i]
    }
}



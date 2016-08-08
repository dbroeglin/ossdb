SIZE = 1000

open('data/hosts.csv', 'w') { |f|
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

open('data/hosts_ips.csv', 'w') { |f|
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

open('data/load_balancers.csv', 'w') { |f|
    f.puts "name,virtualIpv4Address,backendName,backendIpv4Address"
    f.puts "farmxxx,1.0.3.0,primary,10.0.3.0"
    f.puts "farmxxx,1.0.3.0,secondary,10.0.3.1"
    f.puts "farmxxx,1.0.3.0,ternary,10.0.3.2"
    f.puts "farmxxx,1.0.3.0,quaternary,10.0.3.3"
    SIZE.times { |i|
        k = i * 2
        f.puts "farm%03d,1.0.1.%d,primary,10.0.1.%d" % [k, k, i]
        f.puts "farm%03d,1.0.1.%d,secondary,10.0.2.%d" % [k, k, i]
        f.puts "farm%03d,1.0.2.%d,primary,10.100.10.%d" % [k + 1, k, i]
        f.puts "farm%03d,1.0.2.%d,secondary,10.100.11.%d" % [k + 1, k, i]
    }
}

open('data/dns_records.csv', 'w') { |f|
    f.puts "name,type,value"
    f.puts "www.foo.com,A,1.0.3.0"
    f.puts "www.bar.com,A,1.0.4.0"
    f.puts "www.foobar.com,CNAME,www.bar.com"
    SIZE.times { |i|
        k = i * 2
        f.puts "www.foo%03d.com,A,1.0.1.%d" % [i, k]
        f.puts "www.bar%03d.com,A,1.0.2.%d" % [i, k]
    }
}

open('data/apache_services.csv', 'w') { |f|
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



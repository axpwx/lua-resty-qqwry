# lua-resty-qqwry
lua-resty版本的高性能客户端，用于解析纯真社区版IP库(qqwry.dat)

## 状态
此库经过生产环境长期验证

## 主要功能
1. 高性能: qqwry.dat数据库只在nginx启动的时候加载一次，后续完全基于内存查找，零IO
2. 基于FFI的libiconv调用，自动将结果字符集由GBK转为UTF-8

## 安装
```sh
opm get axpwx/lua-resty-qqwry
```

## 使用
```nginx
http {
  init_by_lua_block {
    -- 将/path/to/qqwry.dat换成qqwry.dat的实际地址
    qqwry = require ('resty.qqwry').init('/path/to/qqwry.dat')
  }

  server {
    listen 80;

    location =/ip {
      content_by_lua_block {
        local json = require 'cjson'
        local ip = ngx.var.arg_ip or ngx.var.remote_addr
        local res, err = qqwry:lookup(ip)
        if err then
          ngx.say(err)
          ngx.exit(200)
        end
        ngx.header['Content-Type'] = 'application/json; charset=UTF-8'
        ngx.print(json.encode(res))
      }
    }
}
```
```json
curl http://localhost/ip?ip=223.5.5.5

{"region":"浙江省杭州市","isp":"阿里巴巴anycast公共DNS"}
```

## 性能
> on 2vCPU 2GB mem VM
```sh
wrk -c100 -t2 -d60s "http://10.0.16.15/" -s scripts/random_ip.lua
Running 1m test @ http://10.0.16.15/ip?ip={random_ip}
  2 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     2.08ms  542.36us  16.41ms   96.41%
    Req/Sec    24.28k   776.81    26.23k    81.33%
  2899295 requests in 1.00m, 738.17MB read
Requests/sec:  48320.19
Transfer/sec:     12.30MB
```

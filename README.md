# vpe

Steps to reproduce the issue:

1. `terraform apply`
2. `terraform destroy`

On destroy, it fails randomly for any endpoint with the following error:

```
TestRunDefaultExample 2023-05-18T10:30:23Z retry.go:99: Returning due to fatal error: FatalError{Underlying: error while running command: exit status 1; ╷
Error: [0m Error: [ERROR] Error getting target(r006-2aaa73bd-dc46-411b-aaf7-98cf3c21007a): Target not found
│ {
│     "StatusCode": 404,
│     "Headers": {
│         "Cache-Control": [
│             "max-age=0, no-cache, no-store, must-revalidate"
│         ],
│         "Cf-Cache-Status": [
│             "DYNAMIC"
│         ],
│         "Cf-Ray": [
│             "7c936c22cfe70951-IAD"
│         ],
│         "Content-Type": [
│             "application/json"
│         ],
│         "Date": [
│             "Thu, 18 May 2023 10:30:02 GMT"
│         ],
│         "Expires": [
│             "-1"
│         ],
│         "Pragma": [
│             "no-cache"
│         ],
│         "Server": [
│             "cloudflare"
│         ],
│         "Strict-Transport-Security": [
│             "max-age=31536000; includeSubDomains"
│         ],
│         "Vary": [
│             "Accept-Encoding"
│         ],
│         "X-Content-Type-Options": [
│             "nosniff"
│         ],
│         "X-Request-Id": [
│             "0057c9a8-d8e7-412f-a34b-6b3036565c25"
│         ],
│         "X-Xss-Protection": [
│             "1; mode=block"
│         ]
│     },
│     "Result": {
│         "errors": [
│             {
│                 "code": "not_found",
│                 "message": "Target not found",
│                 "target": {
│                     "name": "id",
│                     "type": "parameter",
│                     "value": "r006-2aaa73bd-dc46-411b-aaf7-98cf3c21007a"
│                 }
│             }
│         ],
│         "trace": "0057c9a8-d8e7-412f-a34b-6b3036565c25"
│     },
│     "RawResult": null
│ }
│ 
│ 
│ 
╵}
```

Now, if you see the target value "r006-2aaa73bd-dc46-411b-aaf7-98cf3c21007a" that's been already destroyed.

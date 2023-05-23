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

Destroy Logs
```
module.vpes.ibm_is_virtual_endpoint_gateway_ip.endpoint_gateway_ip["vpe-default-2hkz3t-vpc-instance-subnet-b-directlink-gateway-2-ip"]:
Destroying...
[id=r006-2aaa73bd-dc46-411b-aaf7-98cf3c21007a/0727-838d6e2f-5379-493e-b341-d8a9ec75df64]
module.vpes.ibm_is_virtual_endpoint_gateway_ip.endpoint_gateway_ip["vpe-default-2hkz3t-vpc-instance-subnet-b-directlink-gateway-2-ip"]: Destruction
complete after 1s
module.vpes.ibm_is_virtual_endpoint_gateway_ip.endpoint_gateway_ip["vpe-default-2hkz3t-vpc-instance-subnet-a-directlink-gateway-1-ip"]:
Destroying...
[id=r006-2aaa73bd-dc46-411b-aaf7-98cf3c21007a/0717-b538d156-35b1-43b3-9f0c-c102cb3dff6c]
module.vpes.ibm_is_virtual_endpoint_gateway_ip.endpoint_gateway_ip["vpe-default-2hkz3t-vpc-instance-subnet-a-directlink-gateway-1-ip"]: Destruction
complete after 1s
module.vpes.ibm_is_virtual_endpoint_gateway_ip.endpoint_gateway_ip["vpe-default-2hkz3t-vpc-instance-subnet-c-directlink-gateway-3-ip"]:
Destroying...
[id=r006-2aaa73bd-dc46-411b-aaf7-98cf3c21007a/0737-b374e7c5-29f8-49a8-9da9-8c75a0fbdc98]
module.vpes.ibm_is_virtual_endpoint_gateway_ip.endpoint_gateway_ip["vpe-default-2hkz3t-vpc-instance-subnet-c-directlink-gateway-3-ip"]: Destruction
complete after 0s
 
module.vpes.ibm_is_subnet_reserved_ip.ip["vpe-default-2hkz3t-vpc-instance-subnet-b-directlink-gateway-2-ip"]:
Destroying...
[id=0727-3479487d-23ad-456c-b274-df0029e4ca6b/0727-838d6e2f-5379-493e-b341-d8a9ec75df64]
module.vpes.ibm_is_subnet_reserved_ip.ip["vpe-default-2hkz3t-vpc-instance-subnet-c-directlink-gateway-3-ip"]:
Destroying...
[id=0737-b736bae7-80fa-462e-94f1-a99405c89b24/0737-b374e7c5-29f8-49a8-9da9-8c75a0fbdc98]
module.vpes.ibm_is_subnet_reserved_ip.ip["vpe-default-2hkz3t-vpc-instance-subnet-b-directlink-gateway-2-ip"]: Destruction
complete after 1s
module.vpes.ibm_is_subnet_reserved_ip.ip["vpe-default-2hkz3t-vpc-instance-subnet-c-directlink-gateway-3-ip"]: Destruction
complete after 1s
module.vpes.ibm_is_subnet_reserved_ip.ip["vpe-default-2hkz3t-vpc-instance-subnet-a-directlink-gateway-1-ip"]:
Destroying...
[id=0717-d10b9267-e847-462c-9ea3-3ea13ec50790/0717-b538d156-35b1-43b3-9f0c-c102cb3dff6c]
module.vpes.ibm_is_subnet_reserved_ip.ip["vpe-default-2hkz3t-vpc-instance-subnet-a-directlink-gateway-1-ip"]: Destruction
complete after 0s
 
module.vpes.ibm_is_virtual_endpoint_gateway.vpe["vpc-instance-directlink"]: Destroying...
[id=r006-2aaa73bd-dc46-411b-aaf7-98cf3c21007a]
module.vpes.ibm_is_virtual_endpoint_gateway.vpe["vpc-instance-directlink"]: Destruction complete
after 2s

```

Now, if you see the target value "r006-2aaa73bd-dc46-411b-aaf7-98cf3c21007a" that's been already destroyed.

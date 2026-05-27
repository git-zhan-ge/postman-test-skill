# Postman 脚本中常用加密实现

## MD5

```javascript

var md5 = CryptoJS.MD5("message").toString();
pm.environment.set("sign", md5);
```



## HMAC-SHA256

```javascript
var hash = CryptoJS.HmacSHA256("message", "secret").toString();
pm.environment.set("hash", hash);
```



## Base64 编码/解码

```javascript
var encoded = CryptoJS.enc.Base64.stringify(CryptoJS.enc.Utf8.parse("hello"));
var decoded = CryptoJS.enc.Utf8.stringify(CryptoJS.enc.Base64.parse(encoded));
```



## AES 加密

```javascript
var encrypted = CryptoJS.AES.encrypt("message", "secret key").toString();
```



> 注意：Postman 沙箱内置了 `crypto-js`，直接使用 `CryptoJS` 对象即可，无需额外引入。
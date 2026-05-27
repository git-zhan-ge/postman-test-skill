# Postman 内置 Chai 断言速查

## 状态码断言

```javascript
pm.test("状态码为200", function () {
    pm.response.to.have.status(200);
});
```

## 响应时间断言

```javascript
pm.test("响应时间小于200ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(200);
});
```

## JSON 响应体断言

```javascript
pm.test("存在 user_id 字段且为数字", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property("user_id");
    pm.expect(jsonData.user_id).to.be.a("number");
});
```

## 数组长度断言

```javascript
pm.test("返回列表数量大于0", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.data.length).to.be.greaterThan(0);
});
```

## 字符串包含

```javascript
pm.test("消息包含成功", function () {
    pm.expect(pm.response.text()).to.include("成功");
});
```
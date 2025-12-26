<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.shop.model.User" %>
<%
    // 从Session中获取用户信息
    User user = (User) session.getAttribute("user");
    String username = (String) session.getAttribute("username");
    boolean isLoggedIn = user != null;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>爱淘宝 - 淘！我喜欢</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/font-awesome@4.7.0/css/font-awesome.min.css">
    <style>
        /* 原有样式保持不变，只修改顶部导航栏的登录部分 */

        .top-nav .fl li {
            float: left;
            margin-right: 15px;
        }

        .top-nav .fl .login {
            color: #ff4400;
        }

        .top-nav .fl .user-info {
            color: #ff4400;
            font-weight: bold;
        }

        .top-nav .fl .logout {
            color: #666;
            margin-left: 10px;
        }

        .top-nav .fl .logout:hover {
            color: #ff4400;
        }
    </style>
</head>
<body>
<!-- 顶部导航栏 - 修改登录部分 -->
<div class="top-nav">
    <div class="container clearfix">
        <ul class="fl">
            <li>中国大陆</li>
            <% if (isLoggedIn) { %>
            <li>
                <span class="user-info">欢迎，<%= username %></span>
                <a href="logout" class="logout">退出</a>
            </li>
            <% } else { %>
            <li><a href="login.jsp" class="login">亲，请登录</a> <a href="register.jsp">免费注册</a></li>
            <% } %>
            <li><a href="#">网页无障碍</a></li>
        </ul>
        <ul class="fr">
            <li><a href="#">淘宝首页</a></li>
            <li><a href="#">已买到的宝贝</a></li>
            <% if (isLoggedIn) { %>
            <li><a href="#">我的淘宝 <i class="fa fa-angle-down"></i></a></li>
            <li><a href="#">购物车 <i class="fa fa-angle-down"></i></a></li>
            <li><a href="#">收藏夹 <i class="fa fa-angle-down"></i></a></li>
            <% } else { %>
            <li><a href="login.jsp">我的淘宝 <i class="fa fa-angle-down"></i></a></li>
            <li><a href="login.jsp">购物车 <i class="fa fa-angle-down"></i></a></li>
            <li><a href="login.jsp">收藏夹 <i class="fa angle-down"></i></a></li>
            <% } %>
            <li><a href="#">免费开店</a></li>
            <li><a href="#">千牛卖家中心</a></li>
            <li><a href="#">帮助中心 <i class="fa fa-angle-down"></i></a></li>
        </ul>
    </div>
</div>

<!-- 其他页面内容保持不变 -->
<!-- ... 原有首页内容 ... -->

<script>
    // 检查登录状态，用于AJAX请求等
    var isLoggedIn = <%= isLoggedIn %>;

    // 如果需要登录的操作
    function requireLogin(action) {
        if (!isLoggedIn) {
            if (confirm('请先登录！是否跳转到登录页面？')) {
                window.location.href = 'login.jsp?redirect=' + encodeURIComponent(window.location.href);
            }
            return false;
        }
        return true;
    }
</script>
</body>
</html>
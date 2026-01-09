package com.shop.controller;

import com.shop.dao.CartDao;
import com.shop.model.CartItem;
import com.shop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CartDao cartDao = new CartDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("add".equals(action)) {
            addToCart(request, response);
        } else if ("view".equals(action)) {
            viewCart(request, response);
        } else if ("remove".equals(action)) {
            removeFromCart(request, response);
        } else if ("update".equals(action)) {
            updateCart(request, response);
        } else if ("clear".equals(action)) {
            clearCart(request, response);
        } else {
            viewCart(request, response);
        }
    }

    // 加入购物车
    private void addToCart(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            String specifications = request.getParameter("specifications");

            cartDao.addToCart(user.getId(), productId, quantity, specifications);
            updateCartSession(session, user.getId());
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("cart?action=view");
    }

    // 查看购物车
    private void viewCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        updateCartSession(session, user.getId());
        request.getRequestDispatcher("cart.jsp").forward(request, response);
    }

    // 更新购物车商品数量
    private void updateCart(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            String specifications = request.getParameter("specifications");

            cartDao.updateQuantity(user.getId(), productId, quantity, specifications);
            updateCartSession(session, user.getId());
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("cart?action=view");
    }

    // 从购物车移除商品
    private void removeFromCart(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            String specifications = request.getParameter("specifications");

            cartDao.deleteCartItem(user.getId(), productId, specifications);
            updateCartSession(session, user.getId());
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("cart?action=view");
    }

    // 清空购物车
    private void clearCart(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        cartDao.clearCart(user.getId());
        session.removeAttribute("cart");
        session.setAttribute("cartCount", 0);
        session.setAttribute("cartTotalAmount", 0.0);

        response.sendRedirect("cart?action=view");
    }

    // 更新购物车Session数据
    private void updateCartSession(HttpSession session, Integer userId) {
        List<CartItem> cart = cartDao.getCartByUserId(userId);
        session.setAttribute("cart", cart);
        session.setAttribute("cartCount", cartDao.getCartCount(userId));
        session.setAttribute("cartTotalAmount", cartDao.getCartTotalAmount(userId));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
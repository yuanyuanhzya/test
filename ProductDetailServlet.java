package com.shop.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.shop.dao.ProductDao;
import com.shop.model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/productDetail")
public class ProductDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        Integer productId = null;
        try {
            productId = Integer.parseInt(req.getParameter("productId"));
        } catch (NumberFormatException e) {
            req.setAttribute("error", "商品ID参数错误");
            req.getRequestDispatcher("error.jsp").forward(req, resp);
            return;
        }

        ProductDao productDao = new ProductDao();
        Product product = productDao.findProductById(productId);
        if (product == null) {
            req.setAttribute("error", "商品不存在");
            req.getRequestDispatcher("error.jsp").forward(req, resp);
            return;
        }

        // 解析规格信息
        Map<String, List<String>> specMap = new HashMap<>();
        List<Map<String, String>> specList = new ArrayList<>();

        String specifications = product.getSpecifications();
        if (specifications != null && !specifications.trim().isEmpty()) {
            try {
                ObjectMapper objectMapper = new ObjectMapper();

                // 尝试解析为JSON格式
                if (specifications.trim().startsWith("{")) {
                    // JSON格式：{"颜色":["红色","蓝色"],"尺寸":["S","M","L"]}
                    Map<String, Object> tempMap = objectMapper.readValue(specifications, Map.class);
                    for (Map.Entry<String, Object> entry : tempMap.entrySet()) {
                        List<String> values = new ArrayList<>();
                        if (entry.getValue() instanceof List) {
                            values = (List<String>) entry.getValue();
                        } else if (entry.getValue() instanceof String) {
                            values.add((String) entry.getValue());
                        }
                        specMap.put(entry.getKey(), values);
                    }
                } else {
                    // 尝试解析为"颜色:红色,蓝色;尺寸:S,M,L"格式
                    String[] specGroups = specifications.split(";");
                    for (String group : specGroups) {
                        if (group.contains(":")) {
                            String[] keyValue = group.split(":", 2);
                            String key = keyValue[0].trim();
                            String valueStr = keyValue[1].trim();

                            List<String> values = new ArrayList<>();
                            if (valueStr.contains(",")) {
                                String[] valueArray = valueStr.split(",");
                                for (String val : valueArray) {
                                    values.add(val.trim());
                                }
                            } else {
                                values.add(valueStr);
                            }

                            specMap.put(key, values);

                            // 同时生成用于JSP显示的结构
                            Map<String, String> specItem = new HashMap<>();
                            specItem.put("name", key);
                            specItem.put("values", String.join(",", values));
                            specList.add(specItem);
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                specMap = new HashMap<>(); // 解析失败时使用空Map
            }
        }

        req.setAttribute("product", product);
        req.setAttribute("specMap", specMap);
        req.setAttribute("specList", specList);

        req.getRequestDispatcher("productDetail.jsp").forward(req, resp);
    }
}
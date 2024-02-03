/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package restaurantmanagement.main;

import java.sql.SQLException;
import java.util.ArrayList;
import restaurantmanagement.data.JDBCConnection;

/**
 *
 * @author snehayenduri
 */
public class Order {
    
    public double createOrder(JDBCConnection conn, ArrayList<OrderItem> ol) throws SQLException{
       int orderId = conn.placeOrder();
       double bill = conn.placeOrderList(orderId, ol);
       return bill;
    }
    
}

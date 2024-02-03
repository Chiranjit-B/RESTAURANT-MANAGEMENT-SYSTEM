/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package restaurantmanagement.data;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import java.sql.CallableStatement;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Random;
import restaurantmanagement.main.MenuDirectory;
import restaurantmanagement.main.OrderItem;
import restaurantmanagement.main.Table;
import restaurantmanagement.main.TableDirectory;
/**
 *
 * @author snehayenduri
 */
public class JDBCConnection {
    private Connection conn;
    private Statement sqlSt;
    private PreparedStatement ps;
    public void getConnection(MenuDirectory menuDirectory, TableDirectory tableDirectory) throws ClassNotFoundException, SQLException{
         try{
           
            String hostname = "localhost";
            String sqlInstanceName = "dcc9e750ef98";
            String sqlDatabase = "RestaurantManagement";
            String sqlUser = "sa";
            String sqlPwd = "Sneha123";

            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            String connectURL = "jdbc:sqlserver://"+hostname+":1433"+
                    ";instance="+sqlInstanceName+";databaseName="+sqlDatabase+";encrypt=true;trustServerCertificate=true;";

            conn = DriverManager.getConnection(connectURL, sqlUser, sqlPwd);
            sqlSt = conn.createStatement();
            
            System.out.println("restaurantmanagement connection successful!");
            
            populatedata(sqlSt, menuDirectory, tableDirectory);
            
        }catch(Exception e){
            e.printStackTrace();
        }
    }

    private void populatedata(Statement sqlSt, MenuDirectory menuDirectory, TableDirectory tableDirectory) throws SQLException {
        //getting menu
            String showMenu = "select * from menu";
            ResultSet rs = sqlSt.executeQuery(showMenu);
            while(rs.next()){
                String itemName = rs.getString("ItemName");
                int itemId = rs.getInt("ItemId");
                double itemPrice = rs.getDouble("ItemPrice");
                menuDirectory.addMenu(itemId, itemName, itemPrice);
               // System.out.println(itemId+" "+itemName+" "+itemPrice);
            }
            
            System.out.println("Total Menu Items"+menuDirectory.getMenuItems().size());
            
            //getting table
            String showTable = "select * from RestaurantTable";
            rs = sqlSt.executeQuery(showTable);
            while(rs.next()){
                int tableNumber = rs.getInt("TableNumber");
                String tableStatus = rs.getString("TableStatus");
                int seatingCapacity = rs.getInt("SeatingCapacity");
                tableDirectory.addTable(tableNumber, tableStatus, seatingCapacity);
               // System.out.println(itemId+" "+itemName+" "+itemPrice);
            }
            System.out.println("Tables:"+tableDirectory.getTableDirectory().size());
    }
    
    public int placeOrder() throws SQLException{
        String q = "INSERT INTO [Order] (OrderDateTime, OrderPrepTime, OrderType, EmpID, CustomerID) VALUES(?,?,?,?,?)";
        ps = conn.prepareStatement(q);
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");  
        LocalDateTime now = LocalDateTime.now();  
        ps.setString(1, String.valueOf(dtf.format(now)));
        Random random = new Random();
        int timeprep = random.ints(10, 30).findFirst().getAsInt();
        ps.setString(2, String.valueOf(timeprep));
        ps.setString(3, "Dine-In");
        int empId = random.ints(2013, 2019).findFirst().getAsInt();
        ps.setInt(4, empId);
        int cusId = random.ints(1000, 1051).findFirst().getAsInt();
        ps.setInt(5, cusId);
        ps.executeUpdate(); 
        
        System.out.println("Placed order..");
        
        ResultSet rs = sqlSt.executeQuery("SELECT max(OrderId) as currentID from [Order]");
        int orderId=0;
        while(rs.next()){
                orderId = rs.getInt("currentID");
        }
        System.out.println("orderid:"+orderId);
        return orderId;
    }
    
    public double placeOrderList(int orderID, ArrayList<OrderItem> ol) throws SQLException{
//        int n=ol.size();
//        System.out.println("restaurantmanagement.data.JDBCConnection.placeOrderList()-"+n);
        for(OrderItem oi : ol){
             String q = "INSERT INTO OrderList (OrderID, ItemID, Quantity) VALUES(?,?,?)";
             ps = conn.prepareStatement(q);
             ps.setInt(1, orderID);
             ps.setInt(2, oi.getItemID());
             ps.setInt(3, oi.getQuantity());
             System.out.println("orderID-"+orderID+" oi.getItemID()-"+oi.getItemID()+"oi.getQuantity()"+oi.getQuantity());
             ps.executeUpdate(); 
        }
        System.out.println("inserted in orderlist..");
        String q = "SELECT OrderAmount FROM [Order] WHERE OrderID="+orderID;
        ResultSet rs = sqlSt.executeQuery(q);
        double orderAmt = 0.0;
        while(rs.next()){
         orderAmt=rs.getDouble("OrderAmount");
        }
        return orderAmt;
    }
    
    public boolean reserveTable(Table table) throws SQLException{
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");  
        LocalDateTime now = LocalDateTime.now();  
        Random random = new Random();
        int custId = random.ints(1000, 1051).findFirst().getAsInt();
        String q ="INSERT INTO Reservation (ReservationDateTime, TableNumber, GuestCount, CustomerID) VALUES(?,?,?,?)";
        ps=conn.prepareStatement(q);
        ps.setString(1, String.valueOf(dtf.format(now)));
        ps.setInt(2, table.getTableNumber());
        ps.setInt(3, table.getSeatingCapacity());
        ps.setInt(4, custId);
        ps.executeUpdate();
        
        return true;
    }
}

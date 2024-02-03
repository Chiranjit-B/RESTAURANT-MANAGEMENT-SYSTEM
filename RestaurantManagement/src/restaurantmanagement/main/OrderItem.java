/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package restaurantmanagement.main;

/**
 *
 * @author snehayenduri
 */
public class OrderItem {
    int ItemID;
    double price;
    double amt;
    int quantity;

    public OrderItem(int ItemID, int quantity, double price) {
        this.ItemID = ItemID;
        this.quantity = quantity;
        this.price = price;
        amt = quantity*price;
    }

    public OrderItem() {
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    
    public int getItemID() {
        return ItemID;
    }

    public void setItemID(int ItemID) {
        this.ItemID = ItemID;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public double getAmt() {
        return amt;
    }

    public void setAmt(double amt) {
        this.amt = amt;
    }
    
    
}

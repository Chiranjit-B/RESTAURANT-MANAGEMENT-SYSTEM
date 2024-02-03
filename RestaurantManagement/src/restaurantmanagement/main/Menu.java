/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package restaurantmanagement.main;

/**
 *
 * @author snehayenduri
 */
public class Menu {
    private int ItemId;
    private String ItemName;
    private double ItemPrice;
    

    public Menu(int ItemId, String ItemName, double ItemPrice) {
        this.ItemId = ItemId;
        this.ItemName = ItemName;
        this.ItemPrice = ItemPrice;
    }

    public Menu() {
    }

    public int getItemId() {
        return ItemId;
    }

    public void setItemId(int ItemId) {
        this.ItemId = ItemId;
    }

    public String getItemName() {
        return ItemName;
    }

    public void setItemName(String ItemName) {
        this.ItemName = ItemName;
    }

    public double getItemPrice() {
        return ItemPrice;
    }

    public void setItemPrice(double ItemPrice) {
        this.ItemPrice = ItemPrice;
    }

    @Override
    public String toString() {
        return ItemName;
    }
    
    
    
}

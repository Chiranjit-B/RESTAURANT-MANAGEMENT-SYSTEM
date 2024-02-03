/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package restaurantmanagement.main;

import java.util.ArrayList;

/**
 *
 * @author snehayenduri
 */
public class MenuDirectory {
    ArrayList<Menu> menuItems = new ArrayList<>();
    
    public Menu addMenu(int itemId, String itemName, double itemPrice){
        Menu menu = new Menu(itemId, itemName, itemPrice);
        menuItems.add(menu);
        return menu;
    }

    public ArrayList<Menu> getMenuItems() {
        return menuItems;
    }

    public void setMenuItems(ArrayList<Menu> menuItems) {
        this.menuItems = menuItems;
    }
    
    
}

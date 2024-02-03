/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package restaurantmanagement.main;

/**
 *
 * @author snehayenduri
 */
public class Table {
    private int tableNumber;
    private String tableStatus;
    private int seatingCapacity;

    public Table() {
    }

    
    public Table(int tableNumber, String tableStatus, int seatingCapacity) {
        this.tableNumber = tableNumber;
        this.tableStatus = tableStatus;
        this.seatingCapacity = seatingCapacity;
    }

    
    
    public int getTableNumber() {
        return tableNumber;
    }

    public void setTableNumber(int tableNumber) {
        this.tableNumber = tableNumber;
    }

    public String getTableStatus() {
        return tableStatus;
    }

    public void setTableStatus(String tableStatus) {
        this.tableStatus = tableStatus;
    }

    public int getSeatingCapacity() {
        return seatingCapacity;
    }

    public void setSeatingCapacity(int seatingCapacity) {
        this.seatingCapacity = seatingCapacity;
    }

    @Override
    public String toString() {
        return String.valueOf(tableNumber);
    }
    
    
}

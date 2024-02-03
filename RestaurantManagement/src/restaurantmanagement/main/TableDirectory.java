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
public class TableDirectory {
    ArrayList<Table> tableDirectory = new ArrayList<>();

    public void addTable(int tableNumber, String tableStatus, int seatingCapacity) {
        Table table = new Table(tableNumber,tableStatus,seatingCapacity);
        tableDirectory.add(table);
    }

    public ArrayList<Table> getTableDirectory() {
        return tableDirectory;
    }

    public void setTableDirectory(ArrayList<Table> tableDirectory) {
        this.tableDirectory = tableDirectory;
    }
    
    
    
}

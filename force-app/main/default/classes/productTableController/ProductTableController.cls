public with sharing class ProductTableController {

    @AuraEnabled(cacheable=true)
    public static List<ProductTable__c> getProducts( String searchKey, String sortBy, String sortDirection) {
        Set<String> allowedSortFields = new Set<String>{'Name', 'Amount__c', 'Price__c', 'ProductType__c', 'ReleaseDate__c', 'Available__c', 'AddedDate__c'};

        if (String.isBlank(sortBy)) {
            sortBy = 'AddedDate__c';
        }

        if (String.isBlank(sortDirection)) {
            sortDirection = 'DESC';
        }

        if (!allowedSortFields.contains(sortBy)) {
            sortBy = 'AddedDate__c';
        }

        if (sortDirection != 'ASC' && sortDirection != 'DESC') {
            sortDirection = 'DESC';
        }


        String baseQuery = 'SELECT Id, Name, Amount__c, Price__c, ProductType__c, ' + 'ReleaseDate__c, Available__c, AddedDate__c ' + 'FROM ProductTable__c';
         
        
        if (String.isNotBlank(searchKey)) {
            baseQuery += ' WHERE Name LIKE \'%' +String.escapeSingleQuotes(searchKey) +'%\'';
        }        

        baseQuery += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        
        return Database.query(baseQuery);  
    }

    @AuraEnabled
    public static ProductTable__c createProduct(ProductTable__c product) {
        insert product;
        return product;
    }

    @AuraEnabled
    public static void deleteProduct(Id productId) {
        delete [SELECT Id FROM ProductTable__c WHERE Id = :productId];
    }

    @AuraEnabled
    public static ProductTable__c updateProduct(ProductTable__c product) {
        update product;
        return product;
    }
}

public class ProductTableTriggerHelper {

    public static void handleBefore(
        List<ProductTable__c> products,
        Boolean isInsert
    ) {
        for (ProductTable__c product : products) {

            if (product.Amount__c != null && product.Amount__c > 0) {
                product.Available__c = true;
            } else {
                product.Available__c = false;
            }

            if (isInsert && product.AddedDate__c == null) {
                product.AddedDate__c = System.now();
            }
        }
    }
}

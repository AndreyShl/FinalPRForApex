@IsTest
public class TestProductTableApplication {


    @testSetup
    static void setupData() {
        List<ProductTable__c> products = new List<ProductTable__c>();

        for (Integer i = 0; i < 5; i++) {
            products.add(new ProductTable__c(
                Name = 'Test Product ' + i,
                Amount__c = 10,
                Price__c = 100,
                ProductType__c = 'TestType',
                ReleaseDate__c = Date.today(),
                Available__c = true
            ));
        }
        insert products;
    }


    @IsTest
    static void testGetProducts() {
        Test.startTest();
        List<ProductTable__c> result = ProductTableController.getProducts(
            'Test',
            'Name',
            'ASC'
        );
        Test.stopTest();

        System.assert(result.size() > 0, 'Products should be returned');
        System.assert(result[0].Name.contains('Test'), 'Name filter should work');
    }

    @IsTest
    static void testCreateProduct() {
        ProductTable__c product = new ProductTable__c(
            Name = 'New Product',
            Amount__c = 5,
            Price__c = 200,
            ProductType__c = 'TestType',
            ReleaseDate__c = Date.today(),
            Available__c = true
        );

        Test.startTest();
        ProductTable__c created = ProductTableController.createProduct(product);
        Test.stopTest();

        System.assertNotEquals(null, created.Id, 'Product should be inserted');
    }

    @IsTest
    static void testUpdateProduct() {
        ProductTable__c product =
            [SELECT Id, Name FROM ProductTable__c LIMIT 1];

        product.Name = 'Updated Name';

        Test.startTest();
        ProductTable__c updated =
            ProductTableController.updateProduct(product);
        Test.stopTest();

        ProductTable__c dbProduct =
            [SELECT Name FROM ProductTable__c WHERE Id = :product.Id];

        System.assertEquals(
            'Updated Name',
            dbProduct.Name,
            'Product name should be updated'
        );
    }

    @IsTest
    static void testDeleteProduct() {
        ProductTable__c product =
            [SELECT Id FROM ProductTable__c LIMIT 1];

        Test.startTest();
        ProductTableController.deleteProduct(product.Id);
        Test.stopTest();

        Integer count =
            [SELECT COUNT() FROM ProductTable__c WHERE Id = :product.Id];

        System.assertEquals(0, count, 'Product should be deleted');
    }

    @IsTest
    static void testTriggerLogic() {
        ProductTable__c product = new ProductTable__c(
            Name = 'Trigger Test',
            Amount__c = 1,
            Price__c = 50,
            ProductType__c = 'TestType',
            ReleaseDate__c = Date.today(),
            Available__c = true
        );

        Test.startTest();
        insert product;
        Test.stopTest();

        ProductTable__c inserted =
            [SELECT AddedDate__c FROM ProductTable__c WHERE Id = :product.Id];

        System.assertNotEquals(
            null,
            inserted.AddedDate__c,
            'Trigger should set AddedDate__c'
        );
    }
}
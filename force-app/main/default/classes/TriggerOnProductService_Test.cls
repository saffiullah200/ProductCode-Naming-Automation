@isTest
public class TriggerOnProductService_Test 
{
    @TestSetup
    public static void testSetup()
    {
        TestFactory factory = new TestFactory(1000);
        factory.createProducts('GenWatt Diesel 1000 kW');
        factory.createProducts('TestProduct');
        
    }
    @isTest
    public static void testInsertProducts() 
    {
        List<Product2> addedProducts = [Select Id, Name, ProductCode 
                                        FROM Product2 
                                        WHERE Name = 'GenWatt Diesel 1000 kW'
                                       ];
        System.assertEquals(1000, TriggerOnProductService.extractMaximumCountFromProductCode(addedProducts));
        addedProducts.clear();
        addedProducts = [Select Id, Name, ProductCode 
                                        FROM Product2 
                                        WHERE Name = 'TestProduct'
                                       ];
        System.assertEquals(1000, TriggerOnProductService.extractMaximumCountFromProductCode(addedProducts));
    }
}
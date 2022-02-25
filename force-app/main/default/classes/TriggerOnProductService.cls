public with sharing class TriggerOnProductService 
{
    public static void checkAndUpdateProductCode(List<Product2> newProducts, Map<Id,Product2> oldProductsMap)
    {
        List<String> productCodes = new List<String>();
        Map<String, List<Product2>> productCodeToProductListMap = new Map<String, List<Product2>>();
        Map<String, Integer> productCodeUpdatedCountMap = new Map<String,Integer>();
        for(Product2 prod : newProducts)   
        {
            if(String.isEmpty(prod.ProductCode))
            {
                productCodes.add(getProductCode(prod.Name));
            }
        }
        //get existing products of same product code
        List<Product2> existingProducts = [SELECT Id, IsProductCodeGeneratedViaTrigger__c, ProductCodeF__c,ProductCode
                                           FROM Product2
                                           WHERE IsProductCodeGeneratedViaTrigger__c = True
                                           AND ProductCodeF__c IN :productCodes
                                           Order By ProductCode DESC];
        for(Product2 existingProd : existingProducts)
        {
            if(productCodeToProductListMap.containsKey(existingProd.ProductCodeF__c))
            {
                productCodeToProductListMap.get(existingProd.ProductCodeF__c).add(existingProd);
            }
            else
            {
                productCodeToProductListMap.put(existingProd.ProductCodeF__c,new List<Product2>{existingProd});
            }
        }
        //create a map to keep the maximum count from the product code
        for(String key : productCodeToProductListMap.keyset())
        {
            productCodeUpdatedCountMap.put(key,extractMaximumCountFromProductCode(productCodeToProductListMap.get(key)));
        }
        for(Product2 prod : newProducts)   
        {
            if(String.isEmpty(prod.ProductCode))
            {
                String productCodeInitials = getProductCode(prod.Name);
                if(productCodeToProductListMap.containsKey(productCodeInitials))
                {
                    Integer count = 0;
                    //get the updated count
                    if(productCodeUpdatedCountMap.containsKey(productCodeInitials))
                    {
                        count = productCodeUpdatedCountMap.get(productCodeInitials);
                    }
                    count += 1;
                    prod.ProductCode = productCodeInitials + String.valueOf(count);
                    prod.IsProductCodeGeneratedViaTrigger__c = true;
                    //keep the updated count to use it for the next product
                    productCodeUpdatedCountMap.put(productCodeInitials,count);
                    
                }
                else
                {
                    prod.ProductCode = productCodeInitials + '1';
                    prod.IsProductCodeGeneratedViaTrigger__c = true;
                    //keep the updated count to use it for the next product
                    productCodeUpdatedCountMap.put(productCodeInitials,1);
                    //add the product to the list of the map so that if the multiple products with the same productcode are inserted, they get the updated productCodecount
                    productCodeToProductListMap.put(productCodeInitials, new List<Product2>{prod});
                }
            }
        }
    }  
    
    public static Integer extractMaximumCountFromProductCode(List<Product2> products)
    {
        //Extract the count from product code
        //if productcode is DP120 (and that product has the maximum count) then function will return 120
        String regex = '[a-zA-Z]';
        Integer maxCount = 0;
        for(Product2 prod : products)
        {
            system.debug(prod);
            if(Integer.valueOf(Prod.ProductCode.replaceAll(regex, '')) > maxCount)
                maxCount = Integer.valueOf(prod.ProductCode.replaceAll(regex, ''));
        }
        return maxCount;
    }
    public static String getProductCode(String productName)
    {
        //if the product has only one word name like "LaptopX" then this code will return "L" as product code
        //Scenario needs to be discussed if we have to handle products which have single name just like we are handling other products 
        
        //concate first character of the product name
        string productCode = productName != '' ? productName.substring(0,1) : '';
        //regex to get first character after each space
        Pattern p = Pattern.compile('\\s.+?');
        Matcher m = p.matcher(productName);
        if(m.find())
        {
            productCode += m.group(0).trim();
        }
        return productCode;
    }
    
}

SELECT MAX(product_variation_inventory)
FROM wish_products_cleaned;

SELECT MAX(inventory_total)
FROM wish_products_cleaned;

SELECT MAX(rating_count)
FROM wish_products_cleaned;

SELECT COUNT(*)
FROM wish_products_cleaned
WHERE price > retail_price;

SELECT TOP 10
title,
price,
retail_price
FROM wish_products_cleaned
WHERE price > retail_price;


SELECT 
AVG(price - retail_price) AS avg_price_difference
FROM wish_products_cleaned
WHERE price > retail_price;

-- price-ისა და retail_price-ის შედარებამ მონაცემთა ბაზაში შეუსაბამობები გამოავლინა.
--ტიპურ ელექტრონულ კომერციაში (e-commerce), გასაყიდი ფასი არ უნდა აღემატებოდეს საცალო ფასს.
--თუმცა, 548 პროდუქტში (ჩანაწერების დაახლოებით 35.6%) price უფრო მეტია, ვიდრე retail_price.
--საშუალო სხვაობა ამ მნიშვნელობებს შორის $1.17-ია, რაც მიუთითებს ფასწარმოქმნის პოტენციურ უზუსტობებზე,
--მონაცემების შეყვანისას დაშვებულ შეცდომებზე ან ფასის ველების არასწორ ინტერპრეტაციაზე.


SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'wish_products_cleaned';

-- ტოპ გაყიდვადი 10 პროდუქტი
SELECT TOP 10
    title,
    units_sold
FROM wish_products_cleaned
ORDER BY units_sold DESC;

--საშუალო ფასი პლატფორმაზე

SELECT
    AVG(price) AS avg_price,
    AVG(retail_price) AS avg_retail_price
FROM wish_products_cleaned;


--ფასდაკლება ზრდის გაყიდვებს? თუ არა?

SELECT
    is_on_sale,
    AVG(units_sold) AS avg_units_sold
FROM wish_products_cleaned
GROUP BY is_on_sale;


-- საუკეთესო merchante - ები გაყიდვებით

SELECT TOP 10
    merchant_name,
    SUM(units_sold) AS total_sales
FROM wish_products_cleaned
GROUP BY merchant_name
ORDER BY total_sales DESC;


--რომელი ქვეყნები ყიდიან ყველაზე ბევრს

SELECT
    origin_country,
    SUM(units_sold) AS total_sales
FROM wish_products_cleaned
GROUP BY origin_country
ORDER BY total_sales DESC;

--რეიტინგების და გაყიდვების კავშირი

SELECT
    ROUND(rating,1) AS rating_group,
    AVG(units_sold) AS avg_sales,
    COUNT(*) AS products
FROM wish_products_cleaned
GROUP BY ROUND(rating,1)
ORDER BY rating_group DESC;

--ანალიზი აჩვენებს, რომ საშუალო რეიტინგის მქონე პროდუქტებს (დაახლოებით 3.8–4.1)
--გაყიდვების ყველაზე მაღალი მაჩვენებელი აქვთ.
--საინტერესოა, რომ პროდუქტებს იდეალური რეიტინგით (5.0) ბევრად დაბალი გაყიდვები აქვთ. 
--ეს მიუთითებს იმაზე, რომ მხოლოდ მაღალი რეიტინგი არ არის „Wish“-ის პლატფორმაზე პროდუქტის წარმატების გარანტია. 

---ყველაზე მაღალი ფასდაკლება

SELECT TOP 10
    title,
    price,
    retail_price,
    discount
FROM wish_products_cleaned
ORDER BY discount DESC;


--discount და sales კვეთა  - არაფერი გამოვლინდა
-- ყველაზე დიდი ფასდაკლების მქონე პროდუქტები საერთოდ არ ხვდებიან ყველაზე გაყიდვად პროდუქტებში
WITH TopDiscount AS (
    SELECT TOP 10 title, discount, units_sold
    FROM wish_products_cleaned
    ORDER BY discount DESC
),
TopSales AS (
    SELECT TOP 10 title, units_sold
    FROM wish_products_cleaned
    ORDER BY units_sold DESC
)

SELECT
    TopDiscount.title,
    TopDiscount.discount,
    TopDiscount.units_sold
FROM TopDiscount
INNER JOIN TopSales
ON TopDiscount.title = TopSales.title;


--უფასო shipping ზრდის გაყიდვებს?

SELECT
    shipping_option_price,
    AVG(units_sold) AS avg_sales
FROM wish_products_cleaned
GROUP BY shipping_option_price
ORDER BY shipping_option_price;

SELECT
    shipping_option_price,
    COUNT(*) AS products,
    AVG(units_sold) AS avg_sales
FROM wish_products_cleaned
GROUP BY shipping_option_price
ORDER BY shipping_option_price;

--ანალიზი აჩვენებს, რომ ბაზარზე დომინირებს და გაყიდვების ყველაზე მაღალ საშუალო მაჩვენებელს აღწევს ის პროდუქტები,
--რომელთა მიწოდების ღირებულება დაბალია (1-დან 3 დოლარამდე). მიწოდების მაღალი ფასები ბევრად იშვიათად გვხვდება 
--და დაკავშირებულია გაყიდვების მნიშვნელოვნად დაბალ მოცულობასთან

SELECT
    shipping_is_express,
    AVG(units_sold) AS avg_sales
FROM wish_products_cleaned
GROUP BY shipping_is_express;

--ანალიზი მიუთითებს, რომ პროდუქტები სტანდარტული მიწოდებით (standard shipping)
--მნიშვნელოვნად მაღალ საშუალო გაყიდვებს აღწევენ, ვიდრე ისინი, რომლებიც ექსპრეს-მიწოდებას 
--(express shipping) სთავაზობენ. ეს იმაზე მეტყველებს, რომ Wish-ის მომხმარებლები პრიორიტეტს
--დაბალ ფასს ანიჭებენ და არა მიწოდების სისწრაფეს.

-- ახდენენ მარკეტინგული ტექსტები გავლენას გაყიდვებზე?
SELECT
    has_urgency,
    AVG(units_sold) AS avg_sales
FROM wish_products_cleaned
GROUP BY has_urgency;

--ანალიზი მიუთითებს, რომ მარკეტინგული აჩქარების სიგნალები (მაგალითად: „მარაგი იწურება“ ან „სწრაფად იყიდება“)
--პროდუქტის გაყიდვებს მნიშვნელოვნად არ ზრდის. იმ პროდუქტებს, რომლებსაც აჩქარების ინდიკატორები არ ჰქონდათ,
--სინამდვილეში ოდნავ მაღალი საშუალო გაყიდვები ჰქონდათ.


--იაფი პროდუქტები ყველაზე მეტად იყიდება?


SELECT
    CASE
        WHEN price < 5 THEN 'Under $5'
        WHEN price < 10 THEN '$5 - $10'
        WHEN price < 20 THEN '$10 - $20'
        ELSE 'Over $20'
    END AS price_group,
    COUNT(*) AS products,
    AVG(units_sold) AS avg_sales
FROM wish_products_cleaned
GROUP BY
    CASE
        WHEN price < 5 THEN 'Under $5'
        WHEN price < 10 THEN '$5 - $10'
        WHEN price < 20 THEN '$10 - $20'
        ELSE 'Over $20'
    END
ORDER BY avg_sales DESC;

--ანალიზი აჩვენებს, რომ Wish-ის პლატფორმაზე გაყიდვების ყველაზე მაღალ საშუალო მაჩვენებელს აღწევს ის პროდუქტები,
--რომელთა ფასი 5-დან 10 დოლარამდეა. უკიდურესად დაბალფასიანი პროდუქტები (5 დოლარზე ნაკლები) ოდნავ უარესად იყიდება,
--ხოლო 10 დოლარზე ზემოთ ფასის მქონე პროდუქტების გაყიდვები საგრძნობლად იკლებს


-- ლოკალური shipping პროდუქტები უფრო კარგად არ იყიდება.
SELECT 
badge_local_product,
AVG(units_sold) AS avg_units_sold,
COUNT(*) AS product_count
FROM wish_products_cleaned
GROUP BY badge_local_product;





-- units_sold სვეტი არ წარმოადგენს გაყიდვების ზუსტ რაოდენობას,
--არამედ Wish-ის პლატფორმის მიერ გამოყენებულ გაყიდვების „ბაკეტებს“ (მაგალითად: 1000+, 5000+, 10000+).
--ეს დასტურდება მონაცემთა ბაზაში არსებული  მნიშვნელობებით (1, 10, 50, 100, 1000, 5000 და ა.შ.).
--შესაბამისად, units_sold ასახავს გაყიდვების მინიმალურ ზღვარს, რაც იმას ნიშნავს, რომ ამ სვეტზე დაყრდნობით 
--გამოთვლილი საშუალო მაჩვენებლები სიფრთხილით უნდა იქნას ინტერპრეტირებული.

SELECT DISTINCT units_sold
FROM wish_products_cleaned
ORDER BY units_sold;



SELECT 
product_color,
SUM(units_sold) AS total_units_sold
FROM wish_products_cleaned
GROUP BY product_color
ORDER BY total_units_sold DESC;



SELECT
CASE
    WHEN product_color LIKE '%black%' THEN 'black'
    WHEN product_color LIKE '%white%' OR product_color = 'ivory' OR product_color = 'offwhite' THEN 'white'
    WHEN product_color LIKE '%grey%' OR product_color LIKE '%gray%' THEN 'gray'
    WHEN product_color LIKE '%blue%' OR product_color = 'navy' THEN 'blue'
    WHEN product_color LIKE '%green%' OR product_color = 'army' THEN 'green'
    WHEN product_color LIKE '%red%' OR product_color LIKE '%wine%' OR product_color = 'claret' THEN 'red'
    WHEN product_color LIKE '%pink%' OR product_color = 'rose' THEN 'pink'
    WHEN product_color LIKE '%yellow%' OR product_color = 'gold' THEN 'yellow'
    WHEN product_color LIKE '%orange%' THEN 'orange'
    WHEN product_color LIKE '%purple%' OR product_color LIKE '%violet%' THEN 'purple'
    WHEN product_color LIKE '%brown%' OR product_color = 'coffee' OR product_color = 'camel' OR product_color = 'khaki' THEN 'brown'
    WHEN product_color = 'Unknown' THEN 'unknown'
    ELSE 'other'
END AS normalized_color,

SUM(units_sold) AS total_units_sold,
COUNT(*) AS product_count

FROM wish_products_cleaned

GROUP BY
CASE
    WHEN product_color LIKE '%black%' THEN 'black'
    WHEN product_color LIKE '%white%' OR product_color = 'ivory' OR product_color = 'offwhite' THEN 'white'
    WHEN product_color LIKE '%grey%' OR product_color LIKE '%gray%' THEN 'gray'
    WHEN product_color LIKE '%blue%' OR product_color = 'navy' THEN 'blue'
    WHEN product_color LIKE '%green%' OR product_color = 'army' THEN 'green'
    WHEN product_color LIKE '%red%' OR product_color LIKE '%wine%' OR product_color = 'claret' THEN 'red'
    WHEN product_color LIKE '%pink%' OR product_color = 'rose' THEN 'pink'
    WHEN product_color LIKE '%yellow%' OR product_color = 'gold' THEN 'yellow'
    WHEN product_color LIKE '%orange%' THEN 'orange'
    WHEN product_color LIKE '%purple%' OR product_color LIKE '%violet%' THEN 'purple'
    WHEN product_color LIKE '%brown%' OR product_color = 'coffee' OR product_color = 'camel' OR product_color = 'khaki' THEN 'brown'
    WHEN product_color = 'Unknown' THEN 'unknown'
    ELSE 'other'
END

ORDER BY total_units_sold DESC;


--ფერების დასახელებების ნორმალიზების შემდეგ, ანალიზი აჩვენებს, რომ გაყიდვებში ნეიტრალური ფერები დომინირებს.
--შავ ფერზე მოდის გაყიდული ერთეულების საერთო რაოდენობის დაახლოებით 24.8%, ხოლო თეთრზე — 17.7%. ეს ნიშნავს,
--რომ მხოლოდ ეს ორი ფერი გაყიდვების დაახლოებით 42%-ს შეადგენს.
--თუ ნაცრისფერსაც (~7.7%) დავამატებთ, ნეიტრალური ტონები ჯამური გაყიდვების დაახლოებით 50%-ს იკავებს,
--რაც მიუთითებს მომხმარებელთა მკაფიო უპირატესობაზე მრავალფეროვანი (versatile) ფერების მიმართ.
--სხვა პოპულარულ ფერებს შორის არის ლურჯი (~8.6%), მწვანე (~7.4%) და წითელი (~7.1%), 
--ხოლო მკვეთრი ფერების — მაგალითად, ყვითლისა (~3.4%) და ნარინჯისფერის (~2.8%) — წილი გაყიდვებში შესამჩნევად დაბალია.
--გარდა ამისა, გაყიდვების დაახლოებით 5% „უცნობი“ (unknown) ფერის კატეგორიაში ხვდება, რაც მიუთითებს მონაცემთა ხარისხის
--გარკვეულ შეზღუდვებზე მოცემულ მონაცემთა ბაზაში




--badge_product_quality და badge_fast_shipping


SELECT
badge_product_quality, 
AVG(units_sold) AS avg_sales
FROM wish_products_cleaned GROUP BY badge_product_quality; 

--ბეჯების (badges) გავლენის ანალიზმა აჩვენა, რომ „Product Quality“ ბეჯის მქონე
--პროდუქტების საშუალო გაყიდვები უფრო მაღალია იმ პროდუქტებთან შედარებით,
--რომლებსაც ეს ბეჯი არ აქვთ. ეს მიუთითებს, რომ პლატფორმის მიერ მინიჭებული ხარისხის ინდიკატორი
--შესაძლოა ზრდიდეს მომხმარებელთა ნდობას და გარკვეულ დადებით გავლენას ახდენდეს გაყიდვებზე.
--თუმცა, შემდგომი კომბინაციური ანალიზი და ყველაზე გაყიდვადი პროდუქტების შეფასება აჩვენებს,
--რომ ბეჯი არ წარმოადგენს წარმატების აუცილებელ ფაქტორს, რადგან ტოპ გაყიდვადი პროდუქტების
--უმეტესობას ეს ბეჯი საერთოდ არ გააჩნია. შესაბამისად, ბეჯები შეიძლება განვიხილოთ როგორც დამატებითი,
--მაგრამ არა გადამწყვეტი სიგნალი პროდუქტის წარმატებისთვის.



SELECT 
CASE 
    WHEN origin_country = 'CN' THEN 'China'
    ELSE 'Other Countries'
END AS product_origin,

COUNT(*) AS product_count,
AVG(price) AS avg_price,
AVG(units_sold) AS avg_units_sold,
AVG(rating) AS avg_rating

FROM wish_products_cleaned

GROUP BY 
CASE 
    WHEN origin_country = 'CN' THEN 'China'
    ELSE 'Other Countries'
END;

--ანალიზი აჩვენებს, რომ პროდუქტების აბსოლუტური უმრავლესობა (დაახლოებით 96%) ჩინური წარმოშობისაა.
--ჩინური პროდუქცია სხვა ქვეყნებისას მცირედით უსწრებს საკვანძო მეტრიკებშიც: მათ აქვთ გაყიდვების უფრო 
--მაღალი საშუალო მაჩვენებელი (4469 ერთეული 3161-ის წინააღმდეგ) და ოდნავ უკეთესი რეიტინგი (3.83 vs 3.73).
--საშუალო ფასები თითქმის იდენტურია. მთლიანობაში, შედეგები მოწმობს, რომ პლატფორმაზე როგორც მიწოდებით, 
--ისე გაყიდვებით ჩინური პროდუქცია დომინირებს.



-- მერჩენტების რეიტინგი მოქმედებს გაყიდვების ეფექტურობაზე და რაოდენობაზე?

SELECT
CASE
    WHEN merchant_rating >= 4.5 THEN '4.5 - 5 (Excellent)'
    WHEN merchant_rating >= 4.0 THEN '4.0 - 4.49 (Very good)'
    WHEN merchant_rating >= 3.5 THEN '3.5 - 3.99 (Good)'
    WHEN merchant_rating >= 3.0 THEN '3.0 - 3.49 (Average)'
    ELSE 'Below 3 (Low)'
END AS rating_group,

COUNT(*) AS product_count,
AVG(units_sold) AS avg_units_sold

FROM wish_products_cleaned

GROUP BY
CASE
    WHEN merchant_rating >= 4.5 THEN '4.5 - 5 (Excellent)'
    WHEN merchant_rating >= 4.0 THEN '4.0 - 4.49 (Very good)'
    WHEN merchant_rating >= 3.5 THEN '3.5 - 3.99 (Good)'
    WHEN merchant_rating >= 3.0 THEN '3.0 - 3.49 (Average)'
    ELSE 'Below 3 (Low)'
END

ORDER BY rating_group DESC;


--ანალიზი აჩვენებს მჭიდრო კავშირს გამყიდველის (merchant) რეიტინგსა და გაყიდვების მაჩვენებელს შორის. 
--იმ გამყიდველების პროდუქცია, რომელთა რეიტინგი 4.0-დან 4.49-მდე მერყეობს, 
--გაყიდვების ყველაზე მაღალ საშუალო მაჩვენებელს აღწევს (~5456 ერთეული). ამის საპირისპიროდ,
--3.5-ზე დაბალი რეიტინგის მქონე გამყიდველებს მნიშვნელოვნად დაბალი გაყიდვები აქვთ. 
--ეს მიუთითებს იმაზე, რომ გამყიდველის მაღალი რეპუტაცია ზრდის მომხმარებლის ნდობას
--და დადებითად აისახება გაყიდვებზე. თუმცა, 4.5+ რეიტინგის ჯგუფში ძალიან ცოტა პროდუქტია წარმოდგენილი,
--ამიტომ ამ კატეგორიისთვის გამოტანილი დასკვნები სიფრთხილით უნდა იქნას ინტერპრეტირებული.


-- რა არის განმაპირობელი იმის რომ ფასდაკლებული ნივთები ამ საიტზე იმდენად კარგად არ იყიდება
-- როგორც ფასდაუკლებელი ნივთები


SELECT
is_on_sale,

COUNT(*) AS product_count,
AVG(units_sold) AS avg_units_sold,
AVG(price) AS avg_price,
AVG(shipping_option_price) AS avg_shipping_price,
AVG(merchant_rating) AS avg_merchant_rating,
AVG(rating) AS avg_product_rating

FROM wish_products_cleaned

GROUP BY is_on_sale;


SELECT top 20
product_color,
COUNT(*) AS discounted_products,
AVG(units_sold) AS avg_units_sold
FROM wish_products_cleaned
WHERE is_on_sale = 1
GROUP BY product_color
ORDER BY discounted_products DESC;

--ფასდაკლებები არაპოპულარულ ფერებზე არ არის მხოლოდ, აქედან გამომდინარე ეს არ არის მიზეზი

--ზომის მიზეზი

SELECT top 20
product_variation_size_id,
AVG(units_sold) AS avg_units_sold
FROM wish_products_cleaned
WHERE is_on_sale = 1
GROUP BY product_variation_size_id
ORDER BY avg_units_sold DESC;


ALTER TABLE wish_products_cleaned
ADD normalized_size NVARCHAR(20);


UPDATE wish_products_cleaned
SET normalized_size =
CASE
    WHEN product_variation_size_id LIKE '%XXXL%' THEN 'XXXL'
    WHEN product_variation_size_id LIKE '%XXL%' THEN 'XXL'
    WHEN product_variation_size_id LIKE '%XL%' THEN 'XL'
    WHEN product_variation_size_id LIKE '%L%' 
         AND product_variation_size_id NOT LIKE '%XL%' THEN 'L'
    WHEN product_variation_size_id LIKE '%M%' THEN 'M'
    WHEN product_variation_size_id LIKE '%S%' 
         AND product_variation_size_id NOT LIKE '%XS%' THEN 'S'
    WHEN product_variation_size_id LIKE '%XS%' THEN 'XS'
    WHEN product_variation_size_id LIKE '%One%' THEN 'One Size'
    ELSE 'Other'
END;



ALTER TABLE wish_products_cleaned
DROP COLUMN product_variation_size_id;


SELECT
normalized_size,
COUNT(*) AS product_count
FROM wish_products_cleaned
GROUP BY normalized_size
ORDER BY product_count DESC;




--შიპინგის მიზეზი

SELECT
is_on_sale,
AVG(shipping_option_price) AS avg_shipping_price
FROM wish_products_cleaned
GROUP BY is_on_sale;

SELECT
normalized_size,
COUNT(*) AS product_count,
AVG(units_sold) AS avg_units_sold
FROM wish_products_cleaned
WHERE is_on_sale = 1
GROUP BY normalized_size
ORDER BY avg_units_sold DESC;

--ფასდაკლებული პროდუქტების ზომების ანალიზი აჩვენებს, რომ გაყიდვების ყველაზე მაღალი მაჩვენებელი საშუალო ზომებს (S, M და XL) აქვთ.
--ექსტრემალურად დიდ ზომებს, როგორიცაა XXL, მნიშვნელოვნად დაბალი გაყიდვები აქვთ, ხოლო XS ზომის მაჩვენებლები
--ასევე საშუალოზე დაბალია. თუმცა, რადგან ყველაზე გავრცელებული ზომები კვლავ ინარჩუნებენ გაყიდვების მაღალ დონეს, 
--ზომა არ იკვეთება, როგორც ძირითადი მიზეზი იმისა, თუ რატომ შეიძლება ჰქონდეს ზოგიერთ ფასდაკლებულ პროდუქტს დაბალი მაჩვენებელი.

--მერჩანტის რეპუტაციის მიზეზი - (აქაც არ არის მიზეზი)

SELECT
is_on_sale,
AVG(merchant_rating) AS avg_merchant_rating
FROM wish_products_cleaned
GROUP BY is_on_sale;


SELECT top 20
value AS tag,
COUNT(*) AS product_count,
AVG(units_sold) AS avg_units_sold
FROM wish_products_cleaned
CROSS APPLY STRING_SPLIT(tags, ',')
GROUP BY value
HAVING COUNT(*) >= 10
ORDER BY avg_units_sold DESC;

--თეგების (tags) ანალიზი აჩვენებს, რომ ყველაზე მაღალი მაჩვენებლების მქონე თეგები ქალის მოდის ისეთ ნივთებს უკავშირდება,
--როგორიცაა „strapless dress“ , „women’s top“ (ქალის ტოპი) და „chiffon blouse“ (შიფონის ბლუზი).




--ფასდაკლებების რანჟირება გაყიდვების მიხედვით - ფასდაკლებების ელასტიურობა

SELECT
CASE
    WHEN (retail_price - price) * 100.0 / retail_price < 10 THEN '0-10%'
    WHEN (retail_price - price) * 100.0 / retail_price < 20 THEN '10-20%'
    WHEN (retail_price - price) * 100.0 / retail_price < 30 THEN '20-30%'
    WHEN (retail_price - price) * 100.0 / retail_price < 40 THEN '30-40%'
    WHEN (retail_price - price) * 100.0 / retail_price < 50 THEN '40-50%'
    ELSE '50%+'
END AS discount_range,

COUNT(*) AS product_count,
AVG(units_sold) AS avg_units_sold

FROM wish_products_cleaned
WHERE retail_price > 0

GROUP BY
CASE
    WHEN (retail_price - price) * 100.0 / retail_price < 10 THEN '0-10%'
    WHEN (retail_price - price) * 100.0 / retail_price < 20 THEN '10-20%'
    WHEN (retail_price - price) * 100.0 / retail_price < 30 THEN '20-30%'
    WHEN (retail_price - price) * 100.0 / retail_price < 40 THEN '30-40%'
    WHEN (retail_price - price) * 100.0 / retail_price < 50 THEN '40-50%'
    ELSE '50%+'
END

ORDER BY avg_units_sold DESC;


--ფასდაკლებების ანალიზი აჩვენებს, რომ გაყიდვების გაზრდისთვის ყველაზე ეფექტური ზომიერი ფასდაკლებებია. 
--30–40%-იანი ფასდაკლების მქონე პროდუქტები გაყიდვების ყველაზე მაღალ საშუალო მაჩვენებელს (~5400 ერთეული) აღწევენ.
--ამის საპირისპიროდ, მცირე ფასდაკლებებს (10–20%) გაყიდვების ყველაზე დაბალი მაჩვენებელი აქვთ, რაც იმაზე მიუთითებს,
--რომ ისინი არ არის საკმარისად ძლიერი სტიმული ყიდვის შესახებ გადაწყვეტილების მისაღებად.
--საინტერესოა, რომ ძალიან დიდი ფასდაკლებები (50%+) არ აჩვენებს უკეთეს შედეგს, ვიდრე ზომიერი ფასდაკლებები.
--ეს მიანიშნებს იმაზე, რომ ექსტრემალურად მაღალ ფასდაკლებებს შეიძლება არ მოჰქონდეს დამატებითი სარგებელი გაყიდვების კუთხით.



-- რეიტინგების რაოდენობის გავლენა გაყიდვებზე - რაც უფრო მეტი შეფასება ანუ რეიტინგი აქვს პროდუქტს ( დადებითი )
-- მეტად სანდოა და უფრო იყიდება თუ არა?

SELECT
CASE
    WHEN rating_count < 50 THEN '0-50 ratings'
    WHEN rating_count < 200 THEN '50-200 ratings'
    WHEN rating_count < 500 THEN '200-500 ratings'
    WHEN rating_count < 1000 THEN '500-1000 ratings'
    ELSE '1000+ ratings'
END AS rating_volume,

COUNT(*) AS product_count,
AVG(units_sold) AS avg_units_sold

FROM wish_products_cleaned

GROUP BY
CASE
    WHEN rating_count < 50 THEN '0-50 ratings'
    WHEN rating_count < 200 THEN '50-200 ratings'
    WHEN rating_count < 500 THEN '200-500 ratings'
    WHEN rating_count < 1000 THEN '500-1000 ratings'
    ELSE '1000+ ratings'
END

ORDER BY avg_units_sold DESC;



--ანალიზი ავლენს ძალიან მჭიდრო კავშირს პროდუქტის მიმოხილვების (reviews) რაოდენობასა და გაყიდვების მაჩვენებელს შორის.
--იმ პროდუქტებს, რომლებსაც 1000-ზე მეტი მიმოხილვა აქვთ, გაყიდვების დრამატულად მაღალი საშუალო მაჩვენებელი აქვთ მათთან შედარებით, 
--ვისაც 50-ზე ნაკლები შეფასება აქვს. ეს კანონზომიერება ხაზს უსვამს „სოციალური მტკიცებულების“ (social proof) 
--მნიშვნელობას ელექტრონულ კომერციაში: პროდუქტები მომხმარებელთა დიდი რაოდენობის გამოხმაურებით უფრო სანდოდ გამოიყურება,
--რაც მნიშვნელოვნად ზრდის მათი შეძენის ალბათობას.




--მარაგების ანალიზი - გავლენა გაყიდვებზე?

SELECT
CASE
    WHEN inventory_total < 10 THEN '0-10 stock'
    WHEN inventory_total < 50 THEN '10-50 stock'
    WHEN inventory_total < 100 THEN '50-100 stock'
    WHEN inventory_total < 200 THEN '100-200 stock'
    ELSE '200+ stock'
END AS stock_level,

COUNT(*) AS product_count,
AVG(units_sold) AS avg_units_sold

FROM wish_products_cleaned

GROUP BY
CASE
    WHEN inventory_total < 10 THEN '0-10 stock'
    WHEN inventory_total < 50 THEN '10-50 stock'
    WHEN inventory_total < 100 THEN '50-100 stock'
    WHEN inventory_total < 200 THEN '100-200 stock'
    ELSE '200+ stock'
END

ORDER BY avg_units_sold DESC;


--მარაგების (inventory) ანალიზი აჩვენებს, რომ მონაცემთა ბაზაში არსებული თითქმის ყველა პროდუქტი
--მარაგის ერთსა და იმავე დიაპაზონში (50–100 ერთეული) ხვდება. ვინაიდან სხვა კატეგორიებში
--ძალიან ცოტა პროდუქტია წარმოდგენილი, რთულია სარწმუნო დასკვნების გამოტანა მარაგების დონესა
--და გაყიდვების მაჩვენებელს შორის კავშირზე. შესაბამისად, მოცემულ მონაცემთა ბაზაში ინვენტარი არ იკვეთება,
--როგორც მნიშვნელოვანი ფაქტორი, რომელიც გაყიდვებში არსებულ სხვაობებს განმარტავს.



--urgency ტექსტები ზრდის გაყიდვებს?


SELECT
has_urgency,
COUNT(*) AS product_count,
AVG(units_sold) AS avg_units_sold
FROM wish_products_cleaned
GROUP BY has_urgency;


SELECT
has_urgency,
COUNT(*) AS high_selling_products
FROM wish_products_cleaned
WHERE units_sold >= 5000
GROUP BY has_urgency;

--პოპულარული პროდუქტების უმეტესობა ისედაც კარგად იყიდება და urgency საერთოდ არ სჭირდება.

SELECT
currency_buyer,
COUNT(*) AS product_count
FROM wish_products_cleaned
GROUP BY currency_buyer
ORDER BY product_count DESC;



-- რეკლამის გავლენა გაყიდვებზე

SELECT
uses_ad_boosts,
COUNT(*) AS product_count,
AVG(units_sold) AS avg_units_sold
FROM wish_products_cleaned
GROUP BY uses_ad_boosts;



--Ad Boost ეფექტიანობა ფასის მიხედვით 

SELECT uses_ad_boosts,
CASE WHEN price < 5 THEN 'Under $5'
WHEN price < 10
THEN '$5-10'
ELSE 'Over $10'
END AS price_range,
AVG(units_sold) AS avg_sales
FROM wish_products_cleaned
GROUP BY uses_ad_boosts,
CASE WHEN price < 5 THEN 'Under $5'
WHEN price < 10 THEN '$5-10'
ELSE 'Over $10' END ORDER BY avg_sales DESC; 

--Ad Boost-ის გამოყენების ანალიზმა აჩვენა, რომ რეკლამირებული პროდუქტები არ აღწევენ მნიშვნელოვნად უფრო მაღალ საშუალო გაყიდვებს.
--ზოგიერთ ფასის კატეგორიაში ad boost-ით რეკლამირებულ პროდუქტებს უფრო დაბალი საშუალო გაყიდვები აქვთ.
--ეს მიუთითებს, რომ რეკლამა პლატფორმაზე არ წარმოადგენს პროდუქტის წარმატების მთავარ ფაქტორს და
--გაყიდვებზე უფრო დიდი გავლენა აქვთ ისეთ მახასიათებლებს,
--როგორიცაა მომხმარებელთა შეფასებების რაოდენობა, მიწოდების ფასი და პროდუქტის ფასი.



SELECT
uses_ad_boosts,
COUNT(*) AS high_selling_products
FROM wish_products_cleaned
WHERE units_sold >= 5000
GROUP BY uses_ad_boosts;

--top 10 პროდუქტი გამოვლენილი ფაქტორების გათვალისწინებით ( რაც გაყიდვებზე დადებითად მოქმედებს )

--„Winning Product Combination“--High Reviews + Low Shipping + Low/Medium Price + Popular Colors + High Merchant Rating


SELECT TOP 10

CASE 
WHEN rating_count >= 1000 THEN 'High Reviews'
WHEN rating_count >= 200 THEN 'Medium Reviews'
ELSE 'Low Reviews'
END AS review_group,

CASE
WHEN discount BETWEEN 30 AND 40 THEN '30-40% Discount'
WHEN discount BETWEEN 20 AND 30 THEN '20-30% Discount'
WHEN discount BETWEEN 10 AND 20 THEN '10-20% Discount'
ELSE 'Other Discount'
END AS discount_group,

CASE
WHEN shipping_option_price <= 2 THEN 'Low Shipping'
WHEN shipping_option_price <= 5 THEN 'Medium Shipping'
ELSE 'High Shipping'
END AS shipping_group,

CASE
WHEN price <= 7 THEN 'Low Price'
WHEN price <= 12 THEN 'Medium Price'
ELSE 'High Price'
END AS price_group,

CASE
WHEN product_color IN ('black','white','blue','gray','grey','green','red')
THEN 'Top Colors'
ELSE 'Other Colors'
END AS color_group,

CASE
WHEN merchant_rating >= 4 THEN 'High Merchant Rating'
ELSE 'Low Merchant Rating'
END AS merchant_group,

CASE
WHEN badge_product_quality = 1 THEN 'Quality Badge'
ELSE 'No Quality Badge'
END AS badge_group,

has_urgency,

COUNT(*) AS product_count,
AVG(units_sold) AS avg_units_sold

FROM wish_products_cleaned

GROUP BY

CASE 
WHEN rating_count >= 1000 THEN 'High Reviews'
WHEN rating_count >= 200 THEN 'Medium Reviews'
ELSE 'Low Reviews'
END,

CASE
WHEN discount BETWEEN 30 AND 40 THEN '30-40% Discount'
WHEN discount BETWEEN 20 AND 30 THEN '20-30% Discount'
WHEN discount BETWEEN 10 AND 20 THEN '10-20% Discount'
ELSE 'Other Discount'
END,

CASE
WHEN shipping_option_price <= 2 THEN 'Low Shipping'
WHEN shipping_option_price <= 5 THEN 'Medium Shipping'
ELSE 'High Shipping'
END,

CASE
WHEN price <= 7 THEN 'Low Price'
WHEN price <= 12 THEN 'Medium Price'
ELSE 'High Price'
END,

CASE
WHEN product_color IN ('black','white','blue','gray','grey','green','red')
THEN 'Top Colors'
ELSE 'Other Colors'
END,

CASE
WHEN merchant_rating >= 4 THEN 'High Merchant Rating'
ELSE 'Low Merchant Rating'
END,

CASE
WHEN badge_product_quality = 1 THEN 'Quality Badge'
ELSE 'No Quality Badge'
END,

has_urgency

HAVING COUNT(*) >= 10

ORDER BY avg_units_sold DESC;




--"Perfect Product" პროფილი რა კომბინაციაა ყველაზე წარმატებული?
-- კარგი merchant + დაბალი shipping + მაღალი reviews ერთდროულად:


SELECT 
CASE WHEN merchant_rating >= 4.0 
AND shipping_option_price <= 3 AND
rating_count >= 500 THEN 'Ideal'
ELSE 'Other' END AS product_profile, 
AVG(units_sold) AS avg_sales,
COUNT(*) AS count
FROM wish_products_cleaned 
GROUP BY CASE WHEN
merchant_rating >= 4.0
AND shipping_option_price <= 3 
AND rating_count >= 500 THEN 'Ideal' 
ELSE 'Other' END; 


--პროდუქტების პროფილის დამატებითმა ანალიზმა აჩვენა, რომ მაღალი რეიტინგის მქონე მერჩანტის, 
--დაბალი მიწოდების ფასისა და მომხმარებელთა შეფასებების დიდი რაოდენობის კომბინაცია 
--მნიშვნელოვნად ზრდის გაყიდვებს. „Ideal“ პროფილის მქონე პროდუქტების 
--საშუალო გაყიდვები დაახლოებით ხუთჯერ აღემატება სხვა პროდუქტების მაჩვენებელს,
--რაც კიდევ ერთხელ ადასტურებს, რომ მომხმარებელთა ნდობა და მიწოდების დაბალი 
--ღირებულება ერთ-ერთი ყველაზე ძლიერი ფაქტორია პროდუქტის წარმატებისთვის.



--ტოპ 10 გაყიდვადი პროდუქტი იმავე პარამეტრებით -- გაშიფრვა იმავე კატეგორიებით ( შემდგომ შედარებისთვის )


SELECT TOP 10

title,
merchant_name,
units_sold,

CASE 
WHEN rating_count >= 1000 THEN 'High Reviews'
WHEN rating_count >= 200 THEN 'Medium Reviews'
ELSE 'Low Reviews'
END AS review_group,

CASE
WHEN discount BETWEEN 30 AND 40 THEN '30-40% Discount'
WHEN discount BETWEEN 20 AND 30 THEN '20-30% Discount'
WHEN discount BETWEEN 10 AND 20 THEN '10-20% Discount'
ELSE 'Other Discount'
END AS discount_group,

CASE
WHEN shipping_option_price <= 2 THEN 'Low Shipping'
WHEN shipping_option_price <= 5 THEN 'Medium Shipping'
ELSE 'High Shipping'
END AS shipping_group,

CASE
WHEN price <= 7 THEN 'Low Price'
WHEN price <= 12 THEN 'Medium Price'
ELSE 'High Price'
END AS price_group,

CASE
WHEN product_color IN ('black','white','blue','gray','grey','green','red')
THEN 'Top Colors'
ELSE 'Other Colors'
END AS color_group,

CASE
WHEN merchant_rating >= 4 THEN 'High Merchant Rating'
ELSE 'Low Merchant Rating'
END AS merchant_group,

CASE
WHEN badge_product_quality = 1 THEN 'Quality Badge'
ELSE 'No Quality Badge'
END AS badge_group,

has_urgency

FROM wish_products_cleaned

ORDER BY units_sold DESC;



--TOP 10 ყველაზე გაყიდვადი პროდუქტების ანალიზმა აჩვენა, რომ ისინი თითქმის სრულად ემთხვევა
--კომბინაციური ანალიზის შედეგად გამოვლენილ წარმატებული პროდუქტის პროფილს.
--აღნიშნული პროდუქტები ხასიათდება მომხმარებელთა შეფასებების მაღალი რაოდენობით,
--დაბალი მიწოდების ფასით, შედარებით დაბალი პროდუქტის ფასით და პოპულარული ფერებით.
--ფასდაკლება და urgency ინდიკატორი არ აღმოჩნდა მნიშვნელოვანი ფაქტორები გაყიდვების ზრდისთვის.

--(High Reviews + Low Shipping + Low Price + Popular Colors)


-- გადავინაცვლოთ ისეთ პროდუქტებზე, რომლებიც ამ "Winning product combination" არ აკმაყოფილებენ
-- მაგრამ მაინც მაღალ გაყიდვებს აღწევენ (Anomalously Successful Products)

SELECT TOP 20
title,
merchant_name,
units_sold,
rating_count,
merchant_rating,
price,
shipping_option_price,
product_color,
discount,

CASE
WHEN badge_product_quality = 1 THEN 'Quality Badge'
ELSE 'No Quality Badge'
END AS badge_group

FROM wish_products_cleaned

WHERE units_sold >= 50000

AND NOT (

rating_count >= 1000
AND shipping_option_price <= 2
AND price <= 12
AND product_color IN ('black','white','blue','gray','grey','green','red')
AND merchant_rating >= 4

)

ORDER BY units_sold DESC;

--განხორციელდა ანომალიების ანალიზი იმ პროდუქტების გამოსავლენად, რომლებიც არ აკმაყოფილებენ წარმატებული 
--პროდუქტის გამოვლენილ კომბინაციას,თუმცა მაინც აღწევენ მაღალ გაყიდვებს.
--ანალიზმა აჩვენა, რომ ზოგიერთი პროდუქტი წარმატებას აღწევს მიუხედავად შედარებით მაღალი მიწოდების ფასისა,
--არაპოპულარული ფერების ან დაბალი მერჩანტის რეიტინგისა.
--აღნიშნული შემთხვევები მიუთითებს, რომ გარკვეულ პროდუქტებს შესაძლოა ჰქონდეთ ტრენდული ან უნიკალური მახასიათებლები,
--რომლებიც მომხმარებლის ინტერესს განსაკუთრებულად იზიდავს.
--შესაბამისად, მიუხედავად ზოგადი ტენდენციებისა, ბაზარზე არსებობს გამონაკლისები, 
--რომლებიც მაღალ გაყიდვებს აღწევენ განსხვავებული ფაქტორების გავლენით.




----------------------------------------------------------------------


---------------------------------------------------
-- POWER BI DATASET PREPARATION
---------------------------------------------------

SELECT *,
CASE
WHEN price < 5 THEN 'Under $5'
WHEN price < 10 THEN '$5-$10'
WHEN price < 20 THEN '$10-$20'
ELSE 'Over $20'
END AS price_group,

CASE
WHEN shipping_option_price <= 2 THEN 'Low Shipping'
WHEN shipping_option_price <= 5 THEN 'Medium Shipping'
ELSE 'High Shipping'
END AS shipping_group,

CASE
WHEN rating_count < 50 THEN '0-50'
WHEN rating_count < 200 THEN '50-200'
WHEN rating_count < 500 THEN '200-500'
WHEN rating_count < 1000 THEN '500-1000'
ELSE '1000+'
END AS review_group,

CASE
WHEN merchant_rating >= 4 THEN 'High Merchant Rating'
ELSE 'Low Merchant Rating'
END AS merchant_group

FROM wish_products_cleaned;


----რევენიუ

SELECT *,
price * units_sold AS revenue
FROM wish_products_cleaned


---
ALTER TABLE wish_products_cleaned
ADD normalized_color NVARCHAR(20);


--
SELECT
origin_country,
COUNT(*) AS products,
AVG(price) AS avg_price,
AVG(units_sold) AS avg_sales
FROM wish_products_cleaned
GROUP BY origin_country
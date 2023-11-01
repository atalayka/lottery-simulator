
<#Function for lottery prediction comparison statics |BAŞLANGIÇ#>
function Get-SplattingPredictionIncidenceStaticsFunction {
    <#
        .SYNOPSIS
        Bu fonksiyon; 1-(60-90) arası altı adet sayıdan oluşan iki adet sistem tahmini (ana tahmin ve ikincil tahmin) üretir. 
        Dışarıdan 1-(60-90) arası altı adet sayıdan oluşan girdi kabul eder, parametresi UserInput'tur. int tipinde girdi alır.
        .PARAMETER UserInput
        UserInput parametresi dışarıdan altı adet 1-90 arası sayı alır. Pipeline ve ya argüman dayatması kabul eder.
        .PARAMETER TopLimit
        TopLimit parametresi tahmin listeleri için üst bir limit belirler.
        .INPUTS
        Bu fonksiyonun girdileri Int32[]'dir
        .OUTPUTS
        Bu fonksiyonun çıktıları genel itibariyle int tipindedir. Basetype tip object olmakla birlikte, çıktılar text olarak verildiği için aktarılmaları mümkün değildir
        Outfile gibi yöntemlerin ya da çıktı aktarım için output streams özelliklerinin denetlenmesi gerekir.
        #>
    param (
        # Dışarıdan girdi parametres, altı adet 1-90 arası sayı alır.
        [Parameter(ValueFromPipeline)]
        [Int32[]]$UserInput,
        # Tahmin grupları için üst limitin belirlendiği parametre, default değeri 60tır.
        [Parameter()]
        [Int32][ValidateRange(60, 90)]$TopLimit = 60,

        #bu fonksiyonun parametrelerinin splat edildiği diğer fonksiyonda kullanılmak üzere parametre
        $RepeatCount
    )
    <#--------------------------------------------------------------------------LEJANT |BAŞLANGIÇ----------------------------------------------------------------------------#>
    <#
        Parameter <UserInput>: Dışarıdan girilecek 1-90 arasındaki altı adet sayı grubunu kabul eder, argüman dayatması veya pipeline yoluyla veri alır. Process bloğunda döndürüldükten sonra kullanılacaktır.   

        Parameter <TopLimit>:  Ana tahmin gruplarının üst sınırlarının kullanıcıdan alındığı parametredir, 6-90 arası sayıları kabul edecektir. Default değeri <60> sayısıdır.

        Variable <CrudeArrayOfPrediction1>: Ham haldeki dizidir, üst sınırı <TopLimit> değişkeni değeridir.

        ArrayList <ShuffledListofPrediction1>: Karıştırılmış dizi 1
        
        Array <IndexestoChoose1>: Karıştırılmış tahmin listesinden seçilecek indeksleri tutan dizi 

        Array <PredictionListCrude1>: Karıştırılmış arraylist <ShuffledListofPrediction1> üzerinden, <IndexestoChoose1> kullanılarak seçilen elemanları tutan dizi

        Variable <CurrentItemOfIndexesToChooseArray1>: Foreach döngüsü içerisine alınan <Indexestochoose> dizisinin mevcuttaki değerini <$PSItem> otomatik değişkeninden alan değişken.

        Array <OutputForPrediction1>: Birinci tahmin listesinin sunum dizisi, çıktı için kullanılıyor.

        Variable <CrudeArrayOfPrediction2>: Ham haldeki dizidir, üst sınırı <TopLimit> değişkeni değeridir.

        ArrayList <ShuffledListofPrediction2>: Karıştırılmış dizi 1
        
        Array <IndexestoChoose2>: Karıştırılmış tahmin listesinden seçilecek indeksleri tutan dizi 

        Array <PredictionListCrude2>: Karıştırılmış arraylist <ShuffledListofPrediction2> üzerinden, <IndexestoChoose2> kullanılarak seçilen elemanları tutan dizi

        Variable <CurrentItemOfIndexesToChooseArray2>: Foreach döngüsü içerisine alınan <Indexestochoose2> dizisinin mevcuttaki değerini <$PSItem> otomatik değişkeninden alan değişken.

        Array <OutputForPrediction2>: ikinci tahmin listesinin sunum dizisi, çıktı için kullanılıyor.

        Array <InputsFromUser>: Pipeline vasıtasıyla UserInput parametresine iletilen argümanların, process blokta teker teker döndürülerek aktarıldığı dizi

        Array <CollisionListOf1and2>: Birincil ve ikincil tahmin listelerinin karşılaştırılması sonucunda çakışan elemanları tutan dizi 

        Array <CollisionListOf1andUserInput>: Birincil ve kullanıcı girdisi listelerinin karşılaştırılması sonucu çakışan elemanları tutan dizi

        Variable(global scope) <$global:CountOfIncidence> 0..6 <Collision> isabet sayılarını gruplara göre tutan global scope değişkenlerdir 0..6 arasında altı adet var.

        Variable(global scope) <$global:CountOfTotalRepeat> toplam kolon sayısını tutan global scope değişkendir

        Variable(global scope) <$global:CountOfTotalIncidence> toplam isabet sayısını tutan global scope değişkendir

        HashTable(global scope) <$global:RepetitionsOfNumbers>: hangi sayının kaç sefer çıktığını tutacaktır
        
        Array <RangeOfIncidence>: En fazla kaç adet isabet bekleneceğini, tahmin dizilerinin sahip olduğu grup sayısından alır ve dizi olarak tutar.

        Variable <ResultOfComb>: Kombinasyon sonucunu integer değerde tutan değişkendir.
        #>
    <#--------------------------------------------------------------------------LEJANT |BİTİŞ--------------------------------------------------------------------------------#>

    Begin {
        "" #Bir satır boşluk

        <#Birincil altı adet sayıdan oluşan tahmin grubunun üretilmesi |BAŞLANGIÇ#>

        #Ham halde, belirli uzunlukta bir dizi üret
        $CrudeArrayOfPrediction1 = 1..$TopLimit

        #Ham haldeki diziyi karıştır ve ArrayList olarak tanımla
        [System.Collections.ArrayList]$ShuffledListofPrediction1 = Get-Random -Shuffle $CrudeArrayOfPrediction1

        #Karıştırılmış dizi içerisinden seçilecek indexleri üret ve bir dizide toparla
        $IndexestoChoose1 = for ($i = 0; $i -lt 6; $i++) {
            #Sayı üret, $shuffledlistofprediction1.Length'i geçmemesi için $TopLimit -1 olacak.
            Get-Random -Minimum 1 -Maximum $($TopLimit - 1)
        }
            
        #Seçilecek indexler <IndexestoChoose1> kullanarak <ShuffledListofPrediction1> adlı listeden elemanlarını seç ve <PredictionListCrude1>'e ata
        #her bir elemanı için <IndexestoChoose1>  dizisinin eleman sayısı kadar kolon et
        #ilk önce en büyük elemanların aradan çıkarılması için, sıralamayı tersine yap
            ($IndexestoChoose1 | Sort-Object -Descending).ForEach({ 

                #mevcut elemanı tut
                $CurrentItemOfIndexesToChooseArray1 = $PSItem

                #<ShuffledListofPrediction1> listesinin, mevcut eleman <CurrentItemOfIndexesToChooseArray1> tarafından tutulan sayısındaki indexi, <PredictionListCrude1> dizisine ata
                [int[]]$PredictionListCrude1 += $ShuffledListofPrediction1[$CurrentItemOfIndexesToChooseArray1]

                #Karışıklık yaratmaması ve kolon listeden aynı elemanın seçilmemesi için, <PredictionListCrude1> dizisine atanan elemanı  <ShuffledListofPrediction1> adlı listeden kaldır
                $ShuffledListofPrediction1.RemoveAt($CurrentItemOfIndexesToChooseArray1)
            })
                
        #Çıktı için diziyi hazırla ve çıktı değişkenine ata
        $OutputForPrediction1 = [int[]]$PredictionListCrude1 | Sort-Object 

        <#Birincil altı adet sayıdan oluşan tahmin grubunun üretilmesi |BİTİŞ#>

        <#İkincil altı adet sayıdan oluşan tahmin grubunun üretilmesi |BAŞLANGIÇ#>

        #Ham halde, belirli uzunlukta bir dizi üret
        $CrudeArrayOfPrediction2 = 1..$TopLimit

        #Ham haldeki diziyi karıştır ve ArrayList olarak tanımla
        [System.Collections.ArrayList]$ShuffledListofPrediction2 = Get-Random -Shuffle $CrudeArrayOfPrediction2

        #Karıştırılmış dizi içerisinden seçilecek indexleri üret ve bir dizide toparla
        $IndexestoChoose2 = for ($i = 0; $i -lt 6; $i++) {
            #Sayı üret, $shuffledlistofprediction1.Length'i geçmemesi için $TopLimit -1 olacak.
            Get-Random -Minimum 1 -Maximum $($TopLimit - 1)
        }
            
        #Seçilecek indexler <IndexestoChoose1> kullanarak <ShuffledListofPrediction1> adlı listeden elemanlarını seç ve <PredictionListCrude1>'e ata
        #her bir elemanı için <IndexestoChoose1>  dizisinin eleman sayısı kadar kolon et
        #ilk önce en büyük elemanların aradan çıkarılması için, sıralamayı tersine yap
            ($IndexestoChoose2 | Sort-Object -Descending).ForEach({ 

                #mevcut elemanı tut
                $CurrentItemOfIndexesToChooseArray2 = $PSItem

                #<ShuffledListofPrediction1> listesinin, mevcut eleman <CurrentItemOfIndexesToChooseArray1> tarafından tutulan sayısındaki indexi, <PredictionListCrude1> dizisine ata
                [int[]]$PredictionListCrude2 += $ShuffledListofPrediction2[$CurrentItemOfIndexesToChooseArray2]

                #Karışıklık yaratmaması ve kolon listeden aynı elemanın seçilmemesi için, <PredictionListCrude1> dizisine atanan elemanı  <ShuffledListofPrediction1> adlı listeden kaldır
                $ShuffledListofPrediction2.RemoveAt($CurrentItemOfIndexesToChooseArray2)
            })
                
        #Çıktı için diziyi hazırla ve çıktı değişkenine ata
        $OutputForPrediction2 = [int[]]$PredictionListCrude2 | Sort-Object 

        <#Birincil altı adet sayıdan oluşan tahmin grubunun üretilmesi |BİTİŞ#>

        <#Ana tahmin ve ikincil tahmin karşılaştırılması sonuçların üretilmesi |BAŞLANGIÇ#>
        $PredictionListCrude1.ForEach({ #Birinci tahmin listesinin (kaba diziden alındı) her biri için dene
                # $PSItem predictionlistcrude1 arrayin her bir elemanını tutuyor olacak
                
                for ($i = 0; $i -lt $PredictionListCrude2.Count; $i++) {
                    #predictionlistcrude2 dizisinin eleman sayısı kadar çalışacaksın.

                    if ($PSItem -eq $PredictionListCrude2[$i]) {
                        #eğer, psitem değişkeninin tuttuğu değer, predictionlistcrude2 dizisinin $i elemanı ile eşleşirse

                        [int[]]$CollisionListOf1and2 += $PSItem #psitem değişkeninin de tuttuğu çakışan elemanları bu diziye ata

                    }
                }
            })
        <#Ana tahmin ve ikincil tahmin karşılaştırılması sonuçların üretilmesi |BİTİŞ #>
    }

    Process {
        #pipeline'a iletilen değerleri teker teker döndürüp; ınputfromuser dizisinde topla
        [int[]]$InputsFromUser += $UserInput
    }

    End {

        <#Ana tahmin ve dışarıdan girilen tahmin karşılaştırılması sonuçların üretilmesi |BAŞLANGIÇ #>
        $PredictionListCrude1.ForEach({ #Birinci tahmin listesinin (kaba diziden alındı) her biri için dene
                # $PSItem predictionlistcrude1 arrayin her bir elemanını tutuyor olacak
            
                for ($i = 0; $i -lt $InputsFromUser.Count; $i++) {
                    #predictionlistcrude2 dizisinin eleman sayısı kadar çalışacaksın.

                    if ($PSItem -eq $InputsFromUser[$i]) {
                        #eğer, psitem değişkeninin tuttuğu değer, predictionlistcrude2 dizisinin $i elemanı ile eşleşirse

                        [int[]]$CollisionListOf1andUserInput += $PSItem #psitem değişkeninin de tuttuğu çakışan elemanları bu diziye ata
                    }
                }
            })
        <#Ana tahmin ve dışarıdan girilen tahmin karşılaştırılması sonuçların üretilmesi |BİTİŞ #>


        <#Çıktılar |BAŞLANGIÇ#>
        #Powershell komut satırı karakter sınırı 192 kadar < - > yazdır
        Write-Host $(("- ") * 50) -ForegroundColor Green 

        Write-Host "T A H M İ N   D İ Z İ L E R İ N İ N   V E R İ L M E S İ   V E   K A R Ş I L A Ş T I R M A L A R I" -ForegroundColor Blue
        <#Ana tahmin ve ikincil tahmin ile alakalı çıktılar |BAŞLANGIÇ#>
        if ($Null -eq $UserInput) {
            #eğer userınput parametresi boş ise

            #Birincil tahmin listesinin çıktısı
            Write-Host "Sistem tarafından üretilen ilk tahmin dizisi_____________: " -NoNewline
            #Birincil tahmin listesinin işaretlendirilmiş çıktısı
            if ($CollisionListOf1and2 -gt 0) {
                #eğer isabet eden sayılar listesi 0dan büyük ise 
                $OutputForPrediction1.ForEach({ #OutputForPrediction1 dizisinin her bir öğesini sına
                        if ($CollisionListOf1and2.Contains($PSItem)) {
                            #eğer mevcut eleman, çakışanlar listesinde varsa
                            Write-Host "$PSItem " -ForegroundColor Green -NoNewline
                        }
                        else {
                            Write-Host "$PSItem " -ForegroundColor Yellow -NoNewline
                        }
                    })
                ""
            }

            else {
                #eğer isabet eden sayı yok ise
                Write-Host $OutputForPrediction1 -ForegroundColor Yellow
            }
            #Birincil tahmin listesinin işaretlendirilmiş çıktısı

            #İkincil tahmin listesinin çıktısı
            Write-Host "Sistem tarafından üretilen ikinci tahmin dizisi__________: " -NoNewline
            #Birincil tahmin listesinin işaretlendirilmiş çıktısı
            if ($CollisionListOf1and2 -gt 0) {
                #eğer isabet eden sayılar listesi 0dan büyük ise 
                $OutputForPrediction2.ForEach({ #OutputForPrediction1 dizisinin her bir öğesini sına
                        if ($CollisionListOf1and2.Contains($PSItem)) {
                            #eğer mevcut eleman, çakışanlar listesinde varsa
                            Write-Host "$PSItem " -ForegroundColor Green -NoNewline
                        }
                        else {
                            Write-Host "$PSItem " -ForegroundColor Yellow -NoNewline
                        }
                    })
                ""
            }
    
            else {
                #eğer isabet eden sayı yok ise
                Write-Host $OutputForPrediction2 -ForegroundColor Yellow
            }

            #ilk ve ikincil tahmin dizilerinin karşılaştırılması
            if ($CollisionListOf1and2.Count -gt 0 ) {
                #çakışan sayı dizisinde eleman var ise
                Write-Host "Karşılaştıran tahmin dizilerinde isabet eden sayılar_____: " -NoNewline

                #Basit string formatlama write-host ile
                Write-Host $($CollisionListOf1and2.ForEach({ "'$PSItem'" })) -ForegroundColor Green
            }

            if ($CollisionListOf1and2.Count -eq 0 ) {
                #eğer çakışan sayı miktarı sıfır ise
                Write-Host 'Mevcut tahminde isabet eden sayı miktarı_________________: ' -NoNewline
                Write-Host $CollisionListOf1and2.Count -ForegroundColor Red -NoNewline
                Write-Host " adet." -ForegroundColor Red

            }
            else {
                #eğer çakışan sayı miktarı sıfır değil ise
                Write-Host 'Mevcut tahminde isabet eden sayı miktarı_________________: ' -NoNewline
                Write-Host $CollisionListOf1and2.Count -ForegroundColor Green -NoNewline
                Write-Host " adet." -ForegroundColor Green
            }
        }
        <#Ana tahmin ve ikincil tahmin ile alakalı çıktılar |BİTİŞ#>

        <#Ana tahmin ve kullanıcı girdisi ile alakalı çıktılar |BAŞLANGIÇ#>
        #ana tahmin ve dışarıdan girdinin renklendirilmiş karşılaştırma çıktıları
        if ($Null -ne $UserInput) {
            #eğer kullanici girişi boş değilse, yani userınput var ise
            #kullanıcı tarafından girilen tahmin listesinin çıktısı

            #Birincil tahmin listesinin çıktısı
            Write-Host "Sistem tarafından üretilen ilk tahmin dizisi_____________: " -NoNewline
            #Birincil tahmin listesinin işaretlendirilmiş çıktısı
            if ($CollisionListOf1andUserInput -gt 0) {
                #eğer isabet eden sayılar listesi 0dan büyük ise 
                $OutputForPrediction1.ForEach({ #OutputForPrediction1 dizisinin her bir öğesini sına
                        if ($CollisionListOf1andUserInput.Contains($PSItem)) {
                            #eğer mevcut eleman, çakışanlar listesinde varsa
                            Write-Host "$PSItem " -ForegroundColor Green -NoNewline
                        }
                        else {
                            Write-Host "$PSItem " -ForegroundColor Yellow -NoNewline
                        }
                    })
                ""
            }

            
            else {
                #eğer isabet eden sayı yok ise
                Write-Host $OutputForPrediction1 -ForegroundColor Yellow
            }
            #Birincil tahmin listesinin işaretlendirilmiş çıktısı

            #İkincil tahmin listesinin çıktısı
            Write-Host "Kullanıcı tarafından sağlanan girdi dizisi_______________: " -NoNewline

            #Birincil tahmin listesinin işaretlendirilmiş çıktısı
            if ($CollisionListOf1andUserInput -gt 0) {
                #eğer isabet eden sayılar listesi 0dan büyük ise 
                $InputsFromUser.ForEach({ #OutputForPrediction1 dizisinin her bir öğesini sına
                        if ($CollisionListOf1andUserInput.Contains($PSItem)) {
                            #eğer mevcut eleman, çakışanlar listesinde varsa
                            Write-Host "$PSItem " -ForegroundColor Green -NoNewline
                        }
                        else {
                            Write-Host "$PSItem " -ForegroundColor Yellow -NoNewline
                        }
                    })
                ""
            }
    
            else {
                #eğer isabet eden sayı yok ise
                Write-Host $InputsFromUser -ForegroundColor Yellow
            }

            #ilk ve ikincil tahmin dizilerinin karşılaştırılması
            if ($CollisionListOf1andUserInput.Count -gt 0 ) {
                #çakışan sayı dizisinde eleman var ise
                Write-Host "Karşılaştırılan tahmin dizilerinde isabet eden sayılar___: " -NoNewline

                #Basit string formatlama write-host ile
                Write-Host $($CollisionListOf1andUserInput.ForEach({ "'$PSItem'" })) -ForegroundColor Green
            }

            if ($CollisionListOf1andUserInput.Count -eq 0 ) {
                #eğer çakışan sayı miktarı sıfır ise
                Write-Host 'Mevcut tahminde isabet eden sayı miktarı_________________: ' -NoNewline
                Write-Host $CollisionListOf1andUserInput.Count -ForegroundColor Red
            }
            else {
                #eğer çakışan sayı miktarı sıfır değil ise
                Write-Host 'Mevcut tahminde isabet eden sayı miktarı_________________: ' -NoNewline
                Write-Host $CollisionListOf1andUserInput.Count -ForegroundColor Green
            }
        }
        <#Ana tahmin ve kullanıcı girdisi ile alakalı çıktılar |BİTİŞ#>
        
       

        <#İsabet eden tahmin gruplarının ve oranlarının çıktıları |BAŞLANGIÇ#>

        if ($Null -ne $UserInput) {
            #kullanıcıdan alınan girdi tahmin listesi için
            if ($CollisionListOf1andUserInput.Count -eq 0) { 
                $Global:CountOfIncidence0Collision++
            }
            if ($CollisionListOf1andUserInput.Count -eq 1) {
                $Global:CountOfIncidence1Collision++
            }
            if ($CollisionListOf1andUserInput.Count -eq 2) {
                $Global:CountOfIncidence2Collision++
            }
            if ($CollisionListOf1andUserInput.Count -eq 3) {
                $Global:CountOfIncidence3Collision++
            }
            if ($CollisionListOf1andUserInput.Count -eq 4) {

                $Global:CountOfIncidence4Collision++
            }
            if ($CollisionListOf1andUserInput.Count -eq 5) {
                $Global:CountOfIncidence5Collision++
            }
            if ($CollisionListOf1andUserInput.Count -eq 6) {
                $Global:CountOfIncidence6Collision++
            }
        }

        if ($Null -eq $UserInput) {
            #sistemden alınan girdi tahmin listesi için
            if ($CollisionListOf1and2.Count -eq 0) { 
                $Global:CountOfIncidence0Collision += 1
            }
            if ($CollisionListOf1and2.Count -eq 1) {
                $Global:CountOfIncidence1Collision += 1
            }
            if ($CollisionListOf1and2.Count -eq 2) {
                $Global:CountOfIncidence2Collision += 1
            }
            if ($CollisionListOf1and2.Count -eq 3) {
                $Global:CountOfIncidence3Collision += 1
            }
            if ($CollisionListOf1and2.Count -eq 4) {
                $Global:CountOfIncidence4Collision += 1
            }
            if ($CollisionListOf1and2.Count -eq 5) {
                $Global:CountOfIncidence5Collision += 1
            }
            if ($CollisionListOf1and2.Count -eq 6) {
                $Global:CountOfIncidence6Collision += 1
            }
        }
        ""
        Write-Host "İ S A B E T   G R U P L A R I N I N   T O P L A M A   A İ T   V E R İ L E R İ" -ForegroundColor Blue

        #TOPLAMLARI HESAPLA
        $Global:CountOfTotalIncidence = $Global:CountOfIncidence1Collision + $Global:CountOfIncidence2Collision + $Global:CountOfIncidence3Collision + $Global:CountOfIncidence4Collision + $Global:CountOfIncidence5Collision + $Global:CountOfIncidence6Collision

        Write-Host 'Toplamda '-NoNewline
        Write-Host "1 " -ForegroundColor Yellow  -NoNewline
        write-host 'isabet bulunan kolon sayısı___________________: ' -NoNewline
        Write-Host $CountOfIncidence1Collision -ForegroundColor Green

        Write-Host 'Toplamda '-NoNewline
        Write-Host "2 " -ForegroundColor Yellow  -NoNewline
        write-host 'isabet bulunan kolon sayısı___________________: ' -NoNewline
        Write-Host $Global:CountOfIncidence2Collision -ForegroundColor Green

        Write-Host 'Toplamda '-NoNewline
        Write-Host "3 " -ForegroundColor Yellow  -NoNewline
        write-host 'isabet bulunan kolon sayısı___________________: ' -NoNewline
        Write-Host $Global:CountOfIncidence3Collision -ForegroundColor Green


        Write-Host 'Toplamda '-NoNewline
        Write-Host "4 " -ForegroundColor Yellow  -NoNewline
        write-host 'isabet bulunan kolon sayısı___________________: ' -NoNewline
        Write-Host $Global:CountOfIncidence4Collision -ForegroundColor Green


        Write-Host 'Toplamda '-NoNewline
        Write-Host "5 " -ForegroundColor Yellow  -NoNewline
        write-host 'isabet bulunan kolon sayısı___________________: ' -NoNewline     
        Write-Host $Global:CountOfIncidence5Collision -ForegroundColor Green


        Write-Host 'Toplamda '-NoNewline
        Write-Host "6 " -ForegroundColor Yellow  -NoNewline
        write-host 'isabet bulunan kolon sayısı___________________: ' -NoNewline        
        Write-Host $Global:CountOfIncidence6Collision -ForegroundColor Green
        
        ""
        Write-Host "İ S A B E T   G R U P L A R I N I N   T O P L A M   İ S A B E T E   O L A N   O R A N L A R I" -ForegroundColor Blue
        #sıfıra bölme hatasını gidermek için, sıfırdan büyük olduğunda oran vermeye başla
        if ($Global:CountOfTotalIncidence -gt 0 ) {
            Write-Host "1 " -ForegroundColor Yellow  -NoNewline
            Write-Host 'adet isabetin toplam isabete oranı_____________________: ' -NoNewline
            Write-Host '%'((($Global:CountOfIncidence1Collision / $Global:CountOfTotalIncidence) ) * 100) -ForegroundColor Green 
        }
        
        if ($Global:CountOfTotalIncidence -gt 0 ) {
            Write-Host "2 " -ForegroundColor Yellow  -NoNewline
            Write-Host 'adet isabetin toplam isabete oranı_____________________: ' -NoNewline
            Write-Host '%'((($Global:CountOfIncidence2Collision / $Global:CountOfTotalIncidence) ) * 100) -ForegroundColor Green
        }

        if ($Global:CountOfTotalIncidence -gt 0 ) {
            Write-Host "3 " -ForegroundColor Yellow  -NoNewline
            Write-Host 'adet isabetin toplam isabete oranı_____________________: ' -NoNewline
            Write-Host '%'((($Global:CountOfIncidence3Collision / $Global:CountOfTotalIncidence) ) * 100) -ForegroundColor Green
        }

        
        if ($Global:CountOfTotalIncidence -gt 0 ) {
            Write-Host "4 " -ForegroundColor Yellow  -NoNewline
            Write-Host 'adet isabetin toplam isabete oranı_____________________: ' -NoNewline
            Write-Host '%'((($Global:CountOfIncidence4Collision / $Global:CountOfTotalIncidence)) * 100) -ForegroundColor Green
        }

        if ($Global:CountOfTotalIncidence -gt 0 ) {
            Write-Host "5 " -ForegroundColor Yellow  -NoNewline
            Write-Host 'adet isabetin toplam isabete oranı_____________________: ' -NoNewline
            Write-Host '%'((($Global:CountOfIncidence5Collision / $Global:CountOfTotalIncidence)) * 100)  -ForegroundColor Green
        }

        if ($Global:CountOfTotalIncidence -gt 0 ) {
            Write-Host "6 " -ForegroundColor Yellow  -NoNewline
            Write-Host 'adet isabetin toplam isabete oranı_____________________: ' -NoNewline
            Write-Host '%'((($Global:CountOfIncidence6Collision / $Global:CountOfTotalIncidence)) * 100) -ForegroundColor Green
        }
      
        ""       
        Write-Host "T O P L A M   T A H M İ N   V E   i S A B E T   S A Y I L A R I" -ForegroundColor Blue
        Write-Host 'Toplamda hiç isabet bulunmayan kolon sayısı______________: ' -NoNewline
        Write-Host $Global:CountOfIncidence0Collision -ForegroundColor Red

        Write-Host 'Toplamda isabet bulunan kolon sayısı_____________________: ' -NoNewline
        Write-Host $Global:CountOfTotalIncidence -ForegroundColor Green

        Write-Host 'Toplam   kolon sayısı____________________________________: ' -NoNewline
        write-host ($Global:CountOfTotalRepeat += 1) -ForegroundColor Yellow
        ""
        <#İsabet eden tahmin gruplarının ve oranlarının çıktıları |BİTİŞ#>

        <#Toplama olan oranlar |BAŞLANGIÇ#>
        Write-Host "T O P L A M   T A H M İ N   V E   i S A B E T   O R A N L A R I" -ForegroundColor Blue

        Write-Host 'Toplam isabetin    toplam kolona oranı___________________: ' -NoNewline
        write-host '%'(($Global:CountOfTotalIncidence / $Global:CountOfTotalRepeat) * 100) -ForegroundColor Green

        Write-Host 'İsabetsiz toplamın toplam kolona oranı___________________: ' -NoNewline
        write-host '%'(($Global:CountOfIncidence0Collision / $Global:CountOfTotalRepeat) * 100) -ForegroundColor Red
        ""

        Write-Host "İ S A B E T   G R U P L A R I N I N  T O P L A M   T A H M İ N E   O R A N L A R I" -ForegroundColor Blue

        Write-Host "1 " -ForegroundColor Yellow  -NoNewline
        Write-Host 'adet isabetin toplam kolona oranı______________________: ' -NoNewline
        write-host '%'(($Global:CountOfIncidence1Collision / $Global:CountOfTotalRepeat) * 100) -ForegroundColor Green

        Write-Host "2 " -ForegroundColor Yellow  -NoNewline
        Write-Host 'adet isabetin toplam kolona oranı______________________: ' -NoNewline
        Write-Host '%'((($Global:CountOfIncidence2Collision / $Global:CountOfTotalRepeat) ) * 100) -ForegroundColor Green
        
        Write-Host "3 " -ForegroundColor Yellow  -NoNewline
        Write-Host 'adet isabetin toplam kolona oranı______________________: ' -NoNewline
        Write-Host '%'((($Global:CountOfIncidence3Collision / $Global:CountOfTotalRepeat) ) * 100) -ForegroundColor Green
    
        Write-Host "4 " -ForegroundColor Yellow  -NoNewline
        Write-Host 'adet isabetin toplam kolona oranı______________________: ' -NoNewline
        Write-Host '%'((($Global:CountOfIncidence4Collision / $Global:CountOfTotalRepeat) ) * 100) -ForegroundColor Green
       
        Write-Host "5 " -ForegroundColor Yellow  -NoNewline
        Write-Host 'adet isabetin toplam kolona oranı______________________: ' -NoNewline
        Write-Host '%'((($Global:CountOfIncidence5Collision / $Global:CountOfTotalRepeat) ) * 100) -ForegroundColor Green
    
        Write-Host "6 " -ForegroundColor Yellow  -NoNewline
        Write-Host 'adet isabetin toplam kolona oranı______________________: ' -NoNewline
        Write-Host '%'((($Global:CountOfIncidence6Collision / $Global:CountOfTotalRepeat) ) * 100) -ForegroundColor Green
    
        <#Toplama olan oranlar |BİTİŞ#>
      
        ""
        Write-Host "İ S A B E T   G R U P L A R I N I N   T O P L A M   İ H T İ M A L L E R E   O L A N   O R A N L A R I" -ForegroundColor Blue

        <#İsabet gruplarının kombinasyon bazlı oranı |BAŞLANGIÇ#>
        #RangeOfIncidence, en fazla kaç adet isabet bulunabileceğini ölçer, değerini tahmin dizisinden alır(6)
        [int[]]$RangeOfIncidence = 1..$OutputForPrediction1.Count 

        write-host "Sayıları   birbirinden   farklı   her   bir   kolon  için: "
        #her bir olası isabet grubu için;
        [int[]]$RangeOfIncidence.ForEach({  
                write-host "$PSItem " -ForegroundColor Yellow -NoNewline
                write-host 'adet isabet için_______________________________________: '  -NoNewline
                #kombinasyon al
                $Fact1 = 1
                for ($i = $TopLimit; $i -gt 1; $i--) {
                    $Fact1 *= $i
                }
                $Fact2 = 1
                for ($j = $PSItem; $j -gt 1; $j--) {
                    $Fact2 *= $j
                }
                $Gap = $TopLimit - $PSItem
                $Fact3 = 1
                for ($k = $Gap; $k -gt 1; $k--) {
                    $Fact3 *= $k
                }
                [int32]$ResultOfComb = $Fact1 / ($Fact2 * $Fact3)
                <#--->Kombinasyon Hesabı<---#>
                # a! / b! x (a-b)!
                Write-Host $($ResultOfComb)  -ForegroundColor Green
            })
        write-host "Kolonda      bir     kesinlikle      isabet       bulunur."

        <#İsabet gruplarının kombinasyon bazlı oranı |BİTİŞ#>
        ""
        Write-Host "İ S A B E T   G R U P L A R I N I N   T O P L A M   O Y N A N A N   K O L O N L A R A   G Ö R E   D A Ğ I L I M L A R I" -ForegroundColor Blue
        <#İsabetlerin bir adet kolona oranı |BAŞLANGIÇ#>
        Write-Host "Hangi    grup    kaç    kolonda     bir    isabet    etti:" 
        try {
            #yazdırmayı dene
            Write-Host "1 " -ForegroundColor Yellow  -NoNewline
            write-host 'adet isabet için_______________________________________: '  -NoNewline
            Write-Host "$($CountOfTotalRepeat / $CountOfIncidence1Collision )" -ForegroundColor Green
        }
        catch {
            #hata bulursan şunu yap
            {}
        }
        try {
    
            Write-Host "2 " -ForegroundColor Yellow  -NoNewline
            write-host 'adet isabet için_______________________________________: '  -NoNewline      
            Write-Host "$($CountOfTotalRepeat / $CountOfIncidence2Collision )" -ForegroundColor Green
        }
        catch {
            {}
        }

        try {
            
            Write-Host "3 " -ForegroundColor Yellow  -NoNewline
            write-host 'adet isabet için_______________________________________: '  -NoNewline      
            Write-Host "$($CountOfTotalRepeat / $CountOfIncidence3Collision )" -ForegroundColor Green
        }
        catch {
            {}
        }
        try {
            Write-Host "4 " -ForegroundColor Yellow  -NoNewline
            write-host 'adet isabet için_______________________________________: '  -NoNewline         
            Write-Host "$($CountOfTotalRepeat / $CountOfIncidence4Collision )" -ForegroundColor Green
        }
        catch {
            {}
        }
        try {
            Write-Host "5 " -ForegroundColor Yellow  -NoNewline
            write-host 'adet isabet için_______________________________________: '  -NoNewline       
            Write-Host "$($CountOfTotalRepeat / $CountOfIncidence5Collision )" -ForegroundColor Green
        }
        catch {
            {}
        }
        try {
            Write-Host "6 " -ForegroundColor Yellow  -NoNewline
            write-host 'adet isabet için_______________________________________: '  -NoNewline       
            Write-Host "$($CountOfTotalRepeat / $CountOfIncidence6Collision )" -ForegroundColor Green
        }
        catch {
            {}

        }
        <#İsabetlerin bir adet kolona oranı |BİTİŞ#>
      
        ""
        <#Hangi sayıdan kaç kez çıktı |BAŞLANGIÇ#>
        if ($Null -eq $UserInput) {
            <# kullanıcı girdisinin olmadığı durumda Sistem tarafından oluşturulan çıktıları işlemek için; #>

            #eğer sistemin ilk döngüsü ise
            if ($CountOfTotalRepeat -eq 1) {
                # sistem tahminleri arasında hangi sayının kaç kez isabet ettiğini tutacak ve sunacaktır.
                [pscustomobject]$Global:RepetitionsOfNumbers = @{
                }
            }

            #eğer çakışan sayı var ise
            while ($null -ne $CollisionListOf1and2) {

                #verilen üst sınır dizisinin her bir elemanı için 
                $CrudeArrayOfPrediction1.foreach({
                        #eğer mevcut dizinin mevcut elemanı, çakışan dizisnde var ise 
                        if ($CollisionListOf1and2.Contains($PSItem)) {

                            #hashtable böyle bir key içeriyor mu kontrol et, içeriyorsa;
                            if ($RepetitionsOfNumbers.ContainsKey($PSItem)) {

                                #bu keyin değerini bir artır.
                                $RepetitionsOfNumbers[$PSItem]++
                            }

                            #eğer içermiyorsa hashte böyle bir key yarat.
                            else {
                                $RepetitionsOfNumbers.Add($PSItem, 1 )
                            }
                        } })
                break
            }
            Write-Host "H A N G İ   S A Y I   T O P L A M D A   K A Ç   S E F E R   Ç I K T I" -ForegroundColor Blue

            #her bir hash öğesi çiftini vermek için sırala, ve her biri için yap;
            $RepetitionsOfNumbers.GetEnumerator() | ForEach-Object { 
                #özel formatta yazdır.
                if ($PSItem.key -lt 10) {
                    #eğer key 10'dan küçük ise
                    write-host $(' {0}           ' -f $PSItem.key) -ForegroundColor Yellow -NoNewline 
                    write-host  'sayısı         ' -NoNewline
                    if ($PSItem.Value -lt 10) {
                        <# Value küçük ise 10 #>
                        write-host $('{0}          ' -f $PSItem.value) -ForegroundColor Green -NoNewline
                        write-host  ' kez             çıktı.'
                    }
                    else {
                        <# değilse #>
                        write-host $('{0}       ' -f $PSItem.value) -ForegroundColor Green -NoNewline
                        write-host  '   kez             çıktı.'
                    }
                    "" 
                }

                else {
                    write-host $('{0}           ' -f $PSItem.key) -ForegroundColor Yellow -NoNewline 
                    write-host  'sayısı         ' -NoNewline

                    if ($PSItem.Value -lt 10) {
                        <# Value küçük ise 10 #>
                        write-host $('{0}          ' -f $PSItem.value) -ForegroundColor Green -NoNewline
                        write-host  ' kez             çıktı.'
                    }
                    else {
                        #eğer değilse
                        write-host $('{0}          ' -f $PSItem.value) -ForegroundColor Green -NoNewline
                        write-host  'kez             çıktı.'
                    }
                    ""
                }
            }
        }
        else {
            #Kullanıcı girdisinin olduğu durumda hangi sayıdan kaç adet isabet alındığını gösterir.

            
            #eğer sistemin ilk döngüsü ise
            if ($CountOfTotalRepeat -eq 1) {
                # sistem tahminleri arasında hangi sayının kaç kez isabet ettiğini tutacak ve sunacaktır.
                [pscustomobject]$Global:RepetitionsOfNumbers = @{
                }
            }

            #eğer çakışan sayı var ise
            while ($null -ne $CollisionListOf1andUserInput) {

                #verilen üst sınır dizisinin her bir elemanı için 
                $CrudeArrayOfPrediction1.foreach({
                        #eğer mevcut dizinin mevcut elemanı, çakışan dizisnde var ise 
                        if ($CollisionListOf1andUserInput.Contains($PSItem)) {

                            #hashtable böyle bir key içeriyor mu kontrol et, içeriyorsa;
                            if ($RepetitionsOfNumbers.ContainsKey($PSItem)) {

                                #bu keyin değerini bir artır.
                                $RepetitionsOfNumbers[$PSItem]++
                            }

                            #eğer içermiyorsa hashte böyle bir key yarat.
                            else {
                                $RepetitionsOfNumbers.Add($PSItem, 1 )
                            }
                        } })
                break
            }
            write-host "Hangi sayıdan kaç tane çıktı_____________________________:"  
            #her bir hash öğesi çiftini vermek için sırala, ve her biri için yap;
            $RepetitionsOfNumbers.GetEnumerator() | ForEach-Object { 
                #özel formatta yazdır.
                if ($PSItem.key -lt 10) {
                    #eğer key 10'dan küçük ise
                    write-host $(' {0}           ' -f $PSItem.key) -ForegroundColor Yellow -NoNewline 
                    write-host  'sayısı         ' -NoNewline
                    if ($PSItem.Value -lt 10) {
                        <# Value küçük ise 10 #>
                        write-host $('{0}          ' -f $PSItem.value) -ForegroundColor Green -NoNewline
                        write-host  ' kez             çıktı.'
                    }
                    else {
                        <# değilse #>
                        write-host $('{0}       ' -f $PSItem.value) -ForegroundColor Green -NoNewline
                        write-host  '   kez             çıktı.'
                    }
                    "" 
                }

                else {
                    write-host $('{0}           ' -f $PSItem.key) -ForegroundColor Yellow -NoNewline 
                    write-host  'sayısı         ' -NoNewline

                    if ($PSItem.Value -lt 10) {
                        <# Value küçük ise 10 #>
                        write-host $('{0}          ' -f $PSItem.value) -ForegroundColor Green -NoNewline
                        write-host  ' kez             çıktı.'
                    }
                    else {
                        #eğer değilse
                        write-host $('{0}          ' -f $PSItem.value) -ForegroundColor Green -NoNewline
                        write-host  'kez             çıktı.'
                    }
                    ""
                }
            }
        }
        <#Hangi sayıdan kaç kez çıktı |BİTİŞ#>
       
        <#Çıktılar |BİTİŞ#>
    }
}


<#Ana fonksiyon |BAŞLANGIÇ#>
function Get-PredictionIncidenceStatics {
    param (
        #kolon sayısı parametresi
        [parameter(Mandatory = $true, Position = 0)][int]$RepeatCount,

        #PSBoundParameter ile splat edilecek parametreler;
        # Dışarıdan girdi parametres, altı adet 1-90 arası sayı alır.
        [Parameter(ValueFromPipeline)]
        [Int32[]]$UserInput,
        # Tahmin grupları için üst limitin belirlendiği parametre, default değeri 60tır.
        [Parameter()]
        [Int32][ValidateRange(6, 90)]$TopLimit
    )
    #parametrelerini bağla;
    for ($i = 0; $i -lt $RepeatCount; $i++) { Get-SplattingPredictionIncidenceStaticsFunction @PSBoundParameters } 
}
<#Ana fonksiyon |BİTİŞ#>


package com.example.calculogastos

data class DadosTecnicos(
    val consumoCidadeGasolina: Double,
    val consumoRodoviaGasolina: Double,
    val consumoCidadeEtanol: Double,
    val consumoRodoviaEtanol: Double,
    val tamanhoTanque: Double,
    val versao: String = ""
)

object CarroDatabase {
    
    private val database = mapOf(
        // Chevrolet Onix (2012-2023)
        "chevrolet|onix|1.0|2013" to DadosTecnicos(9.8, 13.2, 6.8, 9.2, 44.0, "1.0"),
        "chevrolet|onix|1.0|2014" to DadosTecnicos(10.0, 13.5, 7.0, 9.4, 44.0, "1.0"),
        "chevrolet|onix|1.0|2015" to DadosTecnicos(10.2, 13.8, 7.1, 9.6, 44.0, "1.0"),
        "chevrolet|onix|1.0|2016" to DadosTecnicos(10.3, 14.0, 7.2, 9.8, 44.0, "1.0"),
        "chevrolet|onix|1.0|2017" to DadosTecnicos(10.4, 14.1, 7.3, 9.9, 44.0, "1.0"),
        "chevrolet|onix|1.0|2018" to DadosTecnicos(10.5, 14.2, 7.3, 9.9, 44.0, "1.0"),
        "chevrolet|onix|1.0|2019" to DadosTecnicos(10.5, 14.0, 7.3, 9.8, 44.0, "1.0"),
        "chevrolet|onix|1.0|2020" to DadosTecnicos(11.0, 14.5, 7.7, 10.1, 44.0, "1.0 Turbo"),
        "chevrolet|onix|1.0|2021" to DadosTecnicos(11.3, 14.8, 7.9, 10.3, 44.0, "1.0 Turbo"),
        "chevrolet|onix|1.0|2022" to DadosTecnicos(11.5, 15.0, 8.0, 10.5, 44.0, "1.0 Turbo"),
        "chevrolet|onix|1.0|2023" to DadosTecnicos(11.7, 15.2, 8.2, 10.6, 44.0, "1.0 Turbo"),
        "chevrolet|onix|1.4|2013" to DadosTecnicos(9.2, 12.5, 6.4, 8.7, 44.0, "1.4"),
        "chevrolet|onix|1.4|2014" to DadosTecnicos(9.5, 12.8, 6.6, 8.9, 44.0, "1.4"),
        "chevrolet|onix|1.4|2015" to DadosTecnicos(9.7, 13.0, 6.8, 9.1, 44.0, "1.4"),
        
        // Chevrolet Onix Plus
        "chevrolet|onix plus|1.0|2020" to DadosTecnicos(11.2, 14.7, 7.8, 10.2, 44.0, "1.0 Turbo"),
        "chevrolet|onix plus|1.0|2021" to DadosTecnicos(11.5, 15.0, 8.0, 10.5, 44.0, "1.0 Turbo"),
        "chevrolet|onix plus|1.0|2022" to DadosTecnicos(11.7, 15.2, 8.2, 10.6, 44.0, "1.0 Turbo"),
        "chevrolet|onix plus|1.0|2023" to DadosTecnicos(11.9, 15.4, 8.3, 10.7, 44.0, "1.0 Turbo"),
        
        // Chevrolet Prisma
        "chevrolet|prisma|1.0|2013" to DadosTecnicos(10.0, 13.2, 7.0, 9.2, 50.0, "1.0"),
        "chevrolet|prisma|1.0|2014" to DadosTecnicos(10.2, 13.5, 7.1, 9.4, 50.0, "1.0"),
        "chevrolet|prisma|1.0|2015" to DadosTecnicos(10.3, 13.7, 7.2, 9.5, 50.0, "1.0"),
        "chevrolet|prisma|1.0|2016" to DadosTecnicos(10.4, 13.8, 7.3, 9.6, 50.0, "1.0"),
        "chevrolet|prisma|1.0|2017" to DadosTecnicos(10.5, 13.8, 7.3, 9.6, 50.0, "1.0"),
        "chevrolet|prisma|1.0|2018" to DadosTecnicos(10.5, 13.8, 7.3, 9.6, 50.0, "1.0"),
        "chevrolet|prisma|1.4|2013" to DadosTecnicos(9.5, 12.8, 6.6, 8.9, 50.0, "1.4"),
        "chevrolet|prisma|1.4|2014" to DadosTecnicos(9.7, 13.0, 6.8, 9.1, 50.0, "1.4"),
        "chevrolet|prisma|1.4|2015" to DadosTecnicos(9.8, 13.1, 6.8, 9.1, 50.0, "1.4"),
        "chevrolet|prisma|1.4|2016" to DadosTecnicos(10.0, 13.2, 7.0, 9.2, 50.0, "1.4"),
        "chevrolet|prisma|1.4|2017" to DadosTecnicos(10.0, 13.2, 7.0, 9.2, 50.0, "1.4"),
        "chevrolet|prisma|1.4|2018" to DadosTecnicos(10.0, 13.2, 7.0, 9.2, 50.0, "1.4"),
        
        // Chevrolet Cobalt
        "chevrolet|cobalt|1.4|2012" to DadosTecnicos(9.5, 12.8, 6.6, 8.9, 52.0, "1.4"),
        "chevrolet|cobalt|1.4|2013" to DadosTecnicos(9.7, 13.0, 6.8, 9.1, 52.0, "1.4"),
        "chevrolet|cobalt|1.4|2014" to DadosTecnicos(9.8, 13.2, 6.8, 9.2, 52.0, "1.4"),
        "chevrolet|cobalt|1.8|2012" to DadosTecnicos(9.5, 13.0, 6.6, 9.1, 52.0, "1.8"),
        "chevrolet|cobalt|1.8|2013" to DadosTecnicos(9.7, 13.2, 6.8, 9.2, 52.0, "1.8"),
        "chevrolet|cobalt|1.8|2014" to DadosTecnicos(9.8, 13.3, 6.8, 9.3, 52.0, "1.8"),
        "chevrolet|cobalt|1.8|2015" to DadosTecnicos(9.9, 13.4, 6.9, 9.3, 52.0, "1.8"),
        "chevrolet|cobalt|1.8|2016" to DadosTecnicos(10.0, 13.5, 7.0, 9.4, 52.0, "1.8"),
        "chevrolet|cobalt|1.8|2017" to DadosTecnicos(10.0, 13.5, 7.0, 9.4, 52.0, "1.8 Dir.Hidráulica"),
        "chevrolet|cobalt|1.8|2018" to DadosTecnicos(10.5, 14.0, 7.3, 9.8, 52.0, "1.8 Dir.Elétrica"),
        "chevrolet|cobalt|1.8|2019" to DadosTecnicos(10.5, 14.0, 7.3, 9.8, 52.0, "1.8"),
        
        // Chevrolet Tracker
        "chevrolet|tracker|1.0|2021" to DadosTecnicos(10.5, 13.8, 7.3, 9.6, 54.0, "1.0 Turbo"),
        "chevrolet|tracker|1.2|2022" to DadosTecnicos(10.8, 14.2, 7.5, 9.9, 54.0, "1.2 Turbo"),
        "chevrolet|tracker|1.2|2023" to DadosTecnicos(11.0, 14.5, 7.7, 10.1, 54.0, "1.2 Turbo"),
        
        // Fiat Uno (2010-2023)
        "fiat|uno|1.0|2010" to DadosTecnicos(10.0, 13.5, 7.0, 9.4, 48.0, "1.0"),
        "fiat|uno|1.0|2011" to DadosTecnicos(10.2, 13.7, 7.1, 9.5, 48.0, "1.0"),
        "fiat|uno|1.0|2012" to DadosTecnicos(10.3, 13.8, 7.2, 9.6, 48.0, "1.0"),
        "fiat|uno|1.0|2013" to DadosTecnicos(10.5, 14.0, 7.3, 9.8, 48.0, "1.0"),
        "fiat|uno|1.0|2014" to DadosTecnicos(10.6, 14.2, 7.4, 9.9, 48.0, "1.0"),
        "fiat|uno|1.0|2015" to DadosTecnicos(10.7, 14.3, 7.5, 10.0, 48.0, "1.0"),
        "fiat|uno|1.0|2016" to DadosTecnicos(10.8, 14.5, 7.5, 10.1, 48.0, "1.0"),
        "fiat|uno|1.4|2010" to DadosTecnicos(9.5, 12.8, 6.6, 8.9, 48.0, "1.4"),
        "fiat|uno|1.4|2011" to DadosTecnicos(9.6, 13.0, 6.7, 9.1, 48.0, "1.4"),
        "fiat|uno|1.4|2012" to DadosTecnicos(9.7, 13.2, 6.8, 9.2, 48.0, "1.4"),
        
        // Fiat Palio
        "fiat|palio|1.0|2010" to DadosTecnicos(10.0, 13.5, 7.0, 9.4, 48.0, "1.0"),
        "fiat|palio|1.0|2011" to DadosTecnicos(10.2, 13.7, 7.1, 9.5, 48.0, "1.0"),
        "fiat|palio|1.0|2012" to DadosTecnicos(10.3, 13.8, 7.2, 9.6, 48.0, "1.0"),
        "fiat|palio|1.4|2010" to DadosTecnicos(9.5, 12.8, 6.6, 8.9, 48.0, "1.4"),
        "fiat|palio|1.4|2011" to DadosTecnicos(9.7, 13.0, 6.8, 9.1, 48.0, "1.4"),
        "fiat|palio|1.4|2012" to DadosTecnicos(9.8, 13.2, 6.8, 9.2, 48.0, "1.4"),
        
        // Fiat Argo
        "fiat|argo|1.0|2018" to DadosTecnicos(10.8, 14.2, 7.5, 9.9, 48.0, "1.0"),
        "fiat|argo|1.0|2019" to DadosTecnicos(11.0, 14.5, 7.7, 10.1, 48.0, "1.0"),
        "fiat|argo|1.0|2020" to DadosTecnicos(11.2, 14.7, 7.8, 10.2, 48.0, "1.0"),
        "fiat|argo|1.0|2021" to DadosTecnicos(11.5, 15.0, 8.0, 10.5, 48.0, "1.0"),
        "fiat|argo|1.0|2022" to DadosTecnicos(11.7, 15.2, 8.2, 10.6, 48.0, "1.0"),
        "fiat|argo|1.0|2023" to DadosTecnicos(11.9, 15.4, 8.3, 10.7, 48.0, "1.0"),
        "fiat|argo|1.3|2018" to DadosTecnicos(10.0, 13.5, 7.0, 9.4, 48.0, "1.3"),
        "fiat|argo|1.3|2019" to DadosTecnicos(10.2, 13.8, 7.1, 9.6, 48.0, "1.3"),
        "fiat|argo|1.3|2020" to DadosTecnicos(10.5, 14.0, 7.3, 9.8, 48.0, "1.3"),
        "fiat|argo|1.3|2021" to DadosTecnicos(10.7, 14.2, 7.5, 9.9, 48.0, "1.3"),
        "fiat|argo|1.8|2019" to DadosTecnicos(9.5, 12.8, 6.6, 8.9, 48.0, "1.8"),
        "fiat|argo|1.8|2020" to DadosTecnicos(9.8, 13.0, 6.8, 9.1, 48.0, "1.8"),
        "fiat|argo|1.8|2021" to DadosTecnicos(10.0, 13.2, 7.0, 9.2, 48.0, "1.8"),
        
        // Fiat Mobi
        "fiat|mobi|1.0|2017" to DadosTecnicos(11.0, 14.8, 7.7, 10.3, 42.0, "1.0"),
        "fiat|mobi|1.0|2018" to DadosTecnicos(11.2, 15.0, 7.8, 10.5, 42.0, "1.0"),
        "fiat|mobi|1.0|2019" to DadosTecnicos(11.5, 15.2, 8.0, 10.6, 42.0, "1.0"),
        "fiat|mobi|1.0|2020" to DadosTecnicos(11.8, 15.5, 8.2, 10.8, 42.0, "1.0"),
        "fiat|mobi|1.0|2021" to DadosTecnicos(12.0, 15.8, 8.4, 11.0, 42.0, "1.0"),
        "fiat|mobi|1.0|2022" to DadosTecnicos(12.2, 16.0, 8.5, 11.2, 42.0, "1.0"),
        "fiat|mobi|1.0|2023" to DadosTecnicos(12.4, 16.2, 8.7, 11.3, 42.0, "1.0"),
        
        // Fiat Cronos
        "fiat|cronos|1.3|2018" to DadosTecnicos(10.2, 13.8, 7.1, 9.6, 48.0, "1.3"),
        "fiat|cronos|1.3|2019" to DadosTecnicos(10.5, 14.0, 7.3, 9.8, 48.0, "1.3"),
        "fiat|cronos|1.3|2020" to DadosTecnicos(10.8, 14.3, 7.5, 10.0, 48.0, "1.3"),
        "fiat|cronos|1.3|2021" to DadosTecnicos(11.0, 14.5, 7.7, 10.1, 48.0, "1.3"),
        "fiat|cronos|1.8|2018" to DadosTecnicos(9.2, 12.5, 6.4, 8.7, 48.0, "1.8"),
        "fiat|cronos|1.8|2019" to DadosTecnicos(9.5, 12.8, 6.6, 8.9, 48.0, "1.8"),
        "fiat|cronos|1.8|2020" to DadosTecnicos(9.8, 13.0, 6.8, 9.1, 48.0, "1.8"),
        "fiat|cronos|1.8|2021" to DadosTecnicos(10.0, 13.2, 7.0, 9.2, 48.0, "1.8"),
        
        // Volkswagen Gol (2008-2023)
        "volkswagen|gol|1.0|2010" to DadosTecnicos(9.5, 12.8, 6.6, 8.9, 50.0, "1.0"),
        "volkswagen|gol|1.0|2011" to DadosTecnicos(9.7, 13.0, 6.8, 9.1, 50.0, "1.0"),
        "volkswagen|gol|1.0|2012" to DadosTecnicos(9.8, 13.2, 6.8, 9.2, 50.0, "1.0"),
        "volkswagen|gol|1.0|2013" to DadosTecnicos(10.0, 13.3, 7.0, 9.3, 50.0, "1.0"),
        "volkswagen|gol|1.0|2014" to DadosTecnicos(10.0, 13.4, 7.0, 9.3, 50.0, "1.0"),
        "volkswagen|gol|1.0|2015" to DadosTecnicos(10.1, 13.5, 7.0, 9.4, 50.0, "1.0"),
        "volkswagen|gol|1.0|2016" to DadosTecnicos(10.2, 13.5, 7.1, 9.4, 50.0, "1.0"),
        "volkswagen|gol|1.0|2017" to DadosTecnicos(10.2, 13.5, 7.1, 9.4, 50.0, "1.0"),
        "volkswagen|gol|1.0|2018" to DadosTecnicos(10.2, 13.5, 7.1, 9.4, 50.0, "1.0"),
        "volkswagen|gol|1.0|2019" to DadosTecnicos(10.5, 14.0, 7.3, 9.8, 50.0, "1.0"),
        "volkswagen|gol|1.0|2020" to DadosTecnicos(10.8, 14.2, 7.5, 9.9, 50.0, "1.0"),
        "volkswagen|gol|1.0|2021" to DadosTecnicos(11.0, 14.5, 7.7, 10.1, 50.0, "1.0"),
        "volkswagen|gol|1.6|2010" to DadosTecnicos(8.8, 12.0, 6.1, 8.4, 50.0, "1.6"),
        "volkswagen|gol|1.6|2011" to DadosTecnicos(9.0, 12.2, 6.3, 8.5, 50.0, "1.6"),
        "volkswagen|gol|1.6|2012" to DadosTecnicos(9.2, 12.5, 6.4, 8.7, 50.0, "1.6"),
        "volkswagen|gol|1.6|2013" to DadosTecnicos(9.3, 12.6, 6.5, 8.8, 50.0, "1.6"),
        "volkswagen|gol|1.6|2014" to DadosTecnicos(9.4, 12.7, 6.5, 8.8, 50.0, "1.6"),
        "volkswagen|gol|1.6|2015" to DadosTecnicos(9.5, 12.8, 6.6, 8.9, 50.0, "1.6"),
        "volkswagen|gol|1.6|2016" to DadosTecnicos(9.5, 12.8, 6.6, 8.9, 50.0, "1.6"),
        "volkswagen|gol|1.6|2017" to DadosTecnicos(9.5, 12.8, 6.6, 8.9, 50.0, "1.6"),
        "volkswagen|gol|1.6|2018" to DadosTecnicos(9.5, 12.8, 6.6, 8.9, 50.0, "1.6"),
        "volkswagen|gol|1.6|2019" to DadosTecnicos(9.8, 13.0, 6.8, 9.1, 50.0, "1.6"),
        
        // Volkswagen Polo
        "volkswagen|polo|1.0|2018" to DadosTecnicos(10.5, 14.0, 7.3, 9.8, 45.0, "1.0 TSI"),
        "volkswagen|polo|1.0|2019" to DadosTecnicos(10.8, 14.3, 7.5, 10.0, 45.0, "1.0 TSI"),
        "volkswagen|polo|1.0|2020" to DadosTecnicos(11.0, 14.5, 7.7, 10.1, 45.0, "1.0 TSI"),
        "volkswagen|polo|1.0|2021" to DadosTecnicos(11.3, 14.8, 7.9, 10.3, 45.0, "1.0 TSI"),
        "volkswagen|polo|1.0|2022" to DadosTecnicos(11.5, 15.0, 8.0, 10.5, 45.0, "1.0 TSI"),
        "volkswagen|polo|1.0|2023" to DadosTecnicos(11.7, 15.2, 8.2, 10.6, 45.0, "1.0 TSI"),
        "volkswagen|polo|1.6|2010" to DadosTecnicos(9.5, 12.8, 6.6, 8.9, 45.0, "1.6"),
        "volkswagen|polo|1.6|2011" to DadosTecnicos(9.7, 13.0, 6.8, 9.1, 45.0, "1.6"),
        "volkswagen|polo|1.6|2012" to DadosTecnicos(9.8, 13.2, 6.8, 9.2, 45.0, "1.6"),
        "volkswagen|polo|1.6|2013" to DadosTecnicos(10.0, 13.3, 7.0, 9.3, 45.0, "1.6"),
        "volkswagen|polo|1.6|2014" to DadosTecnicos(10.0, 13.4, 7.0, 9.3, 45.0, "1.6"),
        "volkswagen|polo|1.6|2015" to DadosTecnicos(10.1, 13.5, 7.0, 9.4, 45.0, "1.6"),
        "volkswagen|polo|1.6|2016" to DadosTecnicos(10.2, 13.5, 7.1, 9.4, 45.0, "1.6"),
        "volkswagen|polo|1.6|2017" to DadosTecnicos(10.2, 13.5, 7.1, 9.4, 45.0, "1.6"),
        "volkswagen|polo|1.6|2018" to DadosTecnicos(10.2, 13.5, 7.1, 9.4, 45.0, "1.6"),
        "volkswagen|polo|1.6|2019" to DadosTecnicos(10.2, 13.5, 7.1, 9.4, 45.0, "1.6"),
        
        // Volkswagen Virtus
        "volkswagen|virtus|1.0|2018" to DadosTecnicos(10.8, 14.2, 7.5, 9.9, 50.0, "1.0 TSI"),
        "volkswagen|virtus|1.0|2019" to DadosTecnicos(11.0, 14.5, 7.7, 10.1, 50.0, "1.0 TSI"),
        "volkswagen|virtus|1.0|2020" to DadosTecnicos(11.3, 14.8, 7.9, 10.3, 50.0, "1.0 TSI"),
        "volkswagen|virtus|1.0|2021" to DadosTecnicos(11.5, 15.0, 8.0, 10.5, 50.0, "1.0 TSI"),
        "volkswagen|virtus|1.0|2022" to DadosTecnicos(11.7, 15.2, 8.2, 10.6, 50.0, "1.0 TSI"),
        "volkswagen|virtus|1.6|2018" to DadosTecnicos(10.2, 13.8, 7.1, 9.6, 50.0, "1.6"),
        "volkswagen|virtus|1.6|2019" to DadosTecnicos(10.5, 14.0, 7.3, 9.8, 50.0, "1.6"),
        
        // Volkswagen T-Cross
        "volkswagen|t-cross|1.0|2020" to DadosTecnicos(10.2, 13.5, 7.1, 9.4, 50.0, "1.0 TSI"),
        "volkswagen|t-cross|1.0|2021" to DadosTecnicos(10.5, 13.8, 7.3, 9.6, 50.0, "1.0 TSI"),
        "volkswagen|t-cross|1.0|2022" to DadosTecnicos(10.8, 14.0, 7.5, 9.8, 50.0, "1.0 TSI"),
        "volkswagen|t-cross|1.4|2020" to DadosTecnicos(9.5, 12.5, 6.6, 8.7, 50.0, "1.4 TSI"),
        "volkswagen|t-cross|1.4|2021" to DadosTecnicos(9.8, 12.8, 6.8, 8.9, 50.0, "1.4 TSI"),
        
        // Toyota Corolla
        "toyota|corolla|2.0|2015" to DadosTecnicos(10.5, 14.0, 7.3, 9.8, 50.0, "2.0"),
        "toyota|corolla|2.0|2016" to DadosTecnicos(10.8, 14.3, 7.5, 10.0, 50.0, "2.0"),
        "toyota|corolla|2.0|2017" to DadosTecnicos(11.0, 14.5, 7.7, 10.1, 50.0, "2.0"),
        "toyota|corolla|2.0|2018" to DadosTecnicos(11.2, 14.7, 7.8, 10.2, 50.0, "2.0"),
        "toyota|corolla|2.0|2019" to DadosTecnicos(11.3, 14.8, 7.9, 10.3, 50.0, "2.0"),
        "toyota|corolla|2.0|2020" to DadosTecnicos(11.5, 14.8, 8.0, 10.3, 50.0, "2.0"),
        "toyota|corolla|2.0|2021" to DadosTecnicos(11.8, 15.1, 8.2, 10.5, 50.0, "2.0"),
        "toyota|corolla|2.0|2022" to DadosTecnicos(12.0, 15.3, 8.4, 10.7, 50.0, "2.0"),
        "toyota|corolla|2.0|2023" to DadosTecnicos(12.2, 15.5, 8.5, 10.8, 50.0, "2.0"),
        
        // Honda Civic
        "honda|civic|1.8|2010" to DadosTecnicos(9.5, 12.8, 6.6, 8.9, 47.0, "1.8"),
        "honda|civic|1.8|2011" to DadosTecnicos(9.7, 13.0, 6.8, 9.1, 47.0, "1.8"),
        "honda|civic|1.8|2012" to DadosTecnicos(9.8, 13.2, 6.8, 9.2, 47.0, "1.8"),
        "honda|civic|2.0|2013" to DadosTecnicos(10.0, 13.5, 7.0, 9.4, 47.0, "2.0"),
        "honda|civic|2.0|2014" to DadosTecnicos(10.2, 13.7, 7.1, 9.5, 47.0, "2.0"),
        "honda|civic|2.0|2015" to DadosTecnicos(10.3, 13.8, 7.2, 9.6, 47.0, "2.0"),
        "honda|civic|2.0|2016" to DadosTecnicos(10.5, 14.0, 7.3, 9.8, 47.0, "2.0"),
        "honda|civic|2.0|2017" to DadosTecnicos(10.5, 14.0, 7.3, 9.8, 47.0, "2.0"),
        "honda|civic|2.0|2018" to DadosTecnicos(10.8, 14.5, 7.5, 10.1, 47.0, "2.0"),
        "honda|civic|1.5|2017" to DadosTecnicos(11.0, 15.0, 7.7, 10.5, 47.0, "1.5 Turbo"),
        "honda|civic|1.5|2018" to DadosTecnicos(11.2, 15.2, 7.8, 10.6, 47.0, "1.5 Turbo"),
        "honda|civic|1.5|2019" to DadosTecnicos(11.3, 15.3, 7.9, 10.7, 47.0, "1.5 Turbo"),
        "honda|civic|1.5|2020" to DadosTecnicos(11.5, 15.5, 8.0, 10.8, 47.0, "1.5 Turbo"),
        "honda|civic|1.5|2021" to DadosTecnicos(11.8, 15.8, 8.2, 11.0, 47.0, "1.5 Turbo"),
        "honda|civic|1.5|2022" to DadosTecnicos(12.0, 16.0, 8.4, 11.2, 47.0, "1.5 Turbo"),
        
        // Honda Fit
        "honda|fit|1.5|2010" to DadosTecnicos(10.5, 14.0, 7.3, 9.8, 40.0, "1.5"),
        "honda|fit|1.5|2011" to DadosTecnicos(10.7, 14.2, 7.5, 9.9, 40.0, "1.5"),
        "honda|fit|1.5|2012" to DadosTecnicos(10.8, 14.3, 7.5, 10.0, 40.0, "1.5"),
        "honda|fit|1.5|2013" to DadosTecnicos(11.0, 14.5, 7.7, 10.1, 40.0, "1.5"),
        "honda|fit|1.5|2014" to DadosTecnicos(11.0, 14.5, 7.7, 10.1, 40.0, "1.5"),
        "honda|fit|1.5|2015" to DadosTecnicos(11.0, 14.6, 7.7, 10.2, 40.0, "1.5"),
        "honda|fit|1.5|2016" to DadosTecnicos(11.1, 14.7, 7.8, 10.2, 40.0, "1.5"),
        "honda|fit|1.5|2017" to DadosTecnicos(11.2, 14.7, 7.8, 10.2, 40.0, "1.5"),
        "honda|fit|1.5|2018" to DadosTecnicos(11.2, 14.8, 7.8, 10.3, 40.0, "1.5"),
        "honda|fit|1.5|2019" to DadosTecnicos(11.5, 15.0, 8.0, 10.5, 40.0, "1.5"),
        "honda|fit|1.5|2020" to DadosTecnicos(11.8, 15.3, 8.2, 10.7, 40.0, "1.5"),
        
        // Hyundai HB20
        "hyundai|hb20|1.0|2013" to DadosTecnicos(9.8, 13.2, 6.8, 9.2, 50.0, "1.0"),
        "hyundai|hb20|1.0|2014" to DadosTecnicos(10.0, 13.5, 7.0, 9.4, 50.0, "1.0"),
        "hyundai|hb20|1.0|2015" to DadosTecnicos(10.2, 13.7, 7.1, 9.5, 50.0, "1.0"),
        "hyundai|hb20|1.0|2016" to DadosTecnicos(10.3, 13.8, 7.2, 9.6, 50.0, "1.0"),
        "hyundai|hb20|1.0|2017" to DadosTecnicos(10.4, 14.0, 7.3, 9.8, 50.0, "1.0 Turbo"),
        "hyundai|hb20|1.0|2018" to DadosTecnicos(10.5, 14.1, 7.3, 9.8, 50.0, "1.0 Turbo"),
        "hyundai|hb20|1.0|2019" to DadosTecnicos(10.5, 14.2, 7.3, 9.9, 50.0, "1.0 Turbo"),
        "hyundai|hb20|1.0|2020" to DadosTecnicos(11.0, 14.8, 7.7, 10.3, 50.0, "1.0 Turbo"),
        "hyundai|hb20|1.0|2021" to DadosTecnicos(11.2, 15.0, 7.8, 10.5, 50.0, "1.0 Turbo"),
        "hyundai|hb20|1.0|2022" to DadosTecnicos(11.4, 15.2, 8.0, 10.6, 50.0, "1.0 Turbo"),
        "hyundai|hb20|1.6|2013" to DadosTecnicos(9.0, 12.5, 6.3, 8.7, 50.0, "1.6"),
        "hyundai|hb20|1.6|2014" to DadosTecnicos(9.2, 12.7, 6.4, 8.8, 50.0, "1.6"),
        "hyundai|hb20|1.6|2015" to DadosTecnicos(9.5, 13.0, 6.6, 9.1, 50.0, "1.6"),
        "hyundai|hb20|1.6|2016" to DadosTecnicos(9.6, 13.2, 6.7, 9.2, 50.0, "1.6"),
        "hyundai|hb20|1.6|2017" to DadosTecnicos(9.7, 13.3, 6.8, 9.3, 50.0, "1.6"),
        "hyundai|hb20|1.6|2018" to DadosTecnicos(9.8, 13.4, 6.8, 9.3, 50.0, "1.6"),
        "hyundai|hb20|1.6|2019" to DadosTecnicos(9.8, 13.5, 6.8, 9.4, 50.0, "1.6"),
        "hyundai|hb20|1.6|2020" to DadosTecnicos(10.0, 13.8, 7.0, 9.6, 50.0, "1.6"),
        
        // Hyundai Creta
        "hyundai|creta|1.6|2017" to DadosTecnicos(9.2, 12.2, 6.4, 8.5, 53.0, "1.6"),
        "hyundai|creta|1.6|2018" to DadosTecnicos(9.4, 12.4, 6.5, 8.6, 53.0, "1.6"),
        "hyundai|creta|1.6|2019" to DadosTecnicos(9.5, 12.5, 6.6, 8.7, 53.0, "1.6"),
        "hyundai|creta|1.6|2020" to DadosTecnicos(9.8, 13.0, 6.8, 9.1, 53.0, "1.6"),
        "hyundai|creta|1.6|2021" to DadosTecnicos(10.0, 13.2, 7.0, 9.2, 53.0, "1.6"),
        "hyundai|creta|2.0|2017" to DadosTecnicos(8.5, 11.5, 5.9, 8.0, 53.0, "2.0"),
        "hyundai|creta|2.0|2018" to DadosTecnicos(8.7, 11.7, 6.0, 8.1, 53.0, "2.0"),
        "hyundai|creta|2.0|2019" to DadosTecnicos(8.8, 11.8, 6.1, 8.2, 53.0, "2.0"),
        "hyundai|creta|2.0|2020" to DadosTecnicos(9.0, 12.0, 6.3, 8.4, 53.0, "2.0"),
        "hyundai|creta|2.0|2021" to DadosTecnicos(9.2, 12.3, 6.4, 8.6, 53.0, "2.0"),
        
        // Jeep Renegade
        "jeep|renegade|1.8|2016" to DadosTecnicos(8.5, 11.5, 5.9, 8.0, 48.0, "1.8"),
        "jeep|renegade|1.8|2017" to DadosTecnicos(8.7, 11.7, 6.0, 8.1, 48.0, "1.8"),
        "jeep|renegade|1.8|2018" to DadosTecnicos(9.0, 12.0, 6.3, 8.4, 48.0, "1.8"),
        "jeep|renegade|1.8|2019" to DadosTecnicos(9.5, 12.5, 6.6, 8.7, 48.0, "1.8"),
        "jeep|renegade|1.8|2020" to DadosTecnicos(9.8, 12.8, 6.8, 8.9, 48.0, "1.8"),
        "jeep|renegade|1.3|2021" to DadosTecnicos(10.2, 13.5, 7.1, 9.4, 48.0, "1.3 Turbo"),
        "jeep|renegade|1.3|2022" to DadosTecnicos(10.5, 13.8, 7.3, 9.6, 48.0, "1.3 Turbo"),
        
        // Nissan Kicks
        "nissan|kicks|1.6|2017" to DadosTecnicos(9.8, 13.0, 6.8, 9.1, 41.0, "1.6"),
        "nissan|kicks|1.6|2018" to DadosTecnicos(10.0, 13.2, 7.0, 9.2, 41.0, "1.6"),
        "nissan|kicks|1.6|2019" to DadosTecnicos(10.2, 13.5, 7.1, 9.4, 41.0, "1.6"),
        "nissan|kicks|1.6|2020" to DadosTecnicos(10.5, 13.8, 7.3, 9.6, 41.0, "1.6"),
        "nissan|kicks|1.6|2021" to DadosTecnicos(10.8, 14.0, 7.5, 9.8, 41.0, "1.6"),
        "nissan|kicks|1.6|2022" to DadosTecnicos(11.0, 14.2, 7.7, 9.9, 41.0, "1.6"),
        
        // Renault Kwid
        "renault|kwid|1.0|2017" to DadosTecnicos(11.0, 14.8, 7.7, 10.3, 28.0, "1.0"),
        "renault|kwid|1.0|2018" to DadosTecnicos(11.2, 15.0, 7.8, 10.5, 28.0, "1.0"),
        "renault|kwid|1.0|2019" to DadosTecnicos(11.5, 15.2, 8.0, 10.6, 28.0, "1.0"),
        "renault|kwid|1.0|2020" to DadosTecnicos(11.8, 15.5, 8.2, 10.8, 28.0, "1.0"),
        "renault|kwid|1.0|2021" to DadosTecnicos(12.0, 15.8, 8.4, 11.0, 28.0, "1.0"),
        "renault|kwid|1.0|2022" to DadosTecnicos(12.2, 16.0, 8.5, 11.2, 28.0, "1.0")
    )
    
    fun buscarDadosTecnicos(fabricante: String, modelo: String, ano: Int): DadosTecnicos? {
        // Normaliza os dados
        val fabricanteNorm = fabricante.trim().lowercase()
        val modeloNorm = modelo.trim().lowercase()
        
        // Tenta buscar com diferentes motorizações
        val motorizacoes = listOf("1.0", "1.2", "1.3", "1.4", "1.5", "1.6", "1.8", "2.0")
        
        for (motor in motorizacoes) {
            val chave = "$fabricanteNorm|$modeloNorm|$motor|$ano"
            database[chave]?.let { 
                return it 
            }
        }
        
        return null
    }
    
    fun buscarVersoes(fabricante: String, modelo: String, ano: Int): List<DadosTecnicos> {
        val fabricanteNorm = fabricante.trim().lowercase()
        val modeloNorm = modelo.trim().lowercase()
        val anoStr = ano.toString()
        
        return database.filter { (chave, _) ->
            chave.startsWith("$fabricanteNorm|$modeloNorm|") && chave.endsWith("|$anoStr")
        }.map { it.value }
    }
}

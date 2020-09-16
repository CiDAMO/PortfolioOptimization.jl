import pandas as pd
import numpy as np
#import pandas_datareader.data as web
import yfinance as yf
import datetime

lista_acoes_tcc = ["^BVSP",'VALE3.SA','ITUB4.SA','PETR4.SA','BBDC4.SA','B3SA3.SA',
            'PETR3.SA','ABEV3.SA','BBAS3.SA','ITSA4.SA','JBSS3.SA',
            'LREN3.SA','IRBR3.SA','MGLU3.SA','BBDC3.SA','GNDI3.SA',
            'SUZB3.SA','BRFS3.SA','UGPA3.SA','WEGE3.SA','RENT3.SA',
            'RADL3.SA','RAIL3.SA','VIVT4.SA','EQTL3.SA','BBSE3.SA',
            'GGBR4.SA','CCRO3.SA','BRDT3.SA','SBSP3.SA','LAME4.SA',
            'AZUL4.SA','SULA11.SA','COGN3.SA','VVAR3.SA','NTCO3.SA',
            'SANB11.SA','BRML3.SA','YDUQ3.SA','BPAC11.SA','BTOW3.SA',
            'HYPE3.SA','CMIG4.SA','PCAR4.SA','EMBR3.SA','HAPV3.SA',
            'EGIE3.SA','TIMP3.SA','KLBN11.SA','ELET3.SA','QUAL3.SA']

# Para conhecimento 
ibx100 = ['^BVSP',
'ABEV3.SA',
'ALPA4.SA',
'ALSO3.SA',
'AZUL4.SA',
'B3SA3.SA',
'BBAS3.SA',
'BBDC3.SA',
'BBDC4.SA',
'BBSE3.SA',
'BEEF3.SA',
'BIDI11.SA',
'BPAC11.SA',
'BPAN4.SA',
'BRAP4.SA',
'BRDT3.SA',
'BRFS3.SA',
'BRKM5.SA',
'BRML3.SA',
'BRSR6.SA',
'BTOW3.SA',
'CCRO3.SA',
'CESP6.SA',
'CIEL3.SA',
'CMIG4.SA',
'COGN3.SA',
'CPFE3.SA',
'CPLE6.SA',
'CRFB3.SA',
'CSAN3.SA',
'CSMG3.SA',
'CSNA3.SA',
'CVCB3.SA',
'CYRE3.SA',
'DTEX3.SA',
'ECOR3.SA',
'EGIE3.SA',
'ELET3.SA',
'ELET6.SA',
'EMBR3.SA',
'ENBR3.SA',
'ENEV3.SA',
'ENGI11.SA',
'EQTL3.SA',
'EZTC3.SA',
'FLRY3.SA',
'GGBR4.SA',
'GNDI3.SA',
'GOAU4.SA',
'GOLL4.SA',
'HAPV3.SA',
'HGTX3.SA',
'HYPE3.SA',
'IGTA3.SA',
'IRBR3.SA',
'ITSA4.SA',
'ITUB4.SA',
'JBSS3.SA',
'KLBN11.SA',
'LAME4.SA',
'LCAM3.SA',
'LIGT3.SA',
'LINX3.SA',
'LREN3.SA',
'MDIA3.SA',
'MGLU3.SA',
'MOVI3.SA',
'MRFG3.SA',
'MRVE3.SA',
'MULT3.SA',
'MYPK3.SA',
'NEOE3.SA',
'NTCO3.SA',
'PCAR3.SA',
'PETR3.SA',
'PETR4.SA',
'PRIO3.SA',
'PSSA3.SA',
'QUAL3.SA',
'RADL3.SA',
'RAIL3.SA',
'RAPT4.SA',
'RENT3.SA',
'SANB11.SA',
'SAPR11.SA',
'SBSP3.SA',
'SMLS3.SA',
'SULA11.SA',
'SUZB3.SA',
'TAEE11.SA',
'TCSA3.SA',
'TIMP3.SA',
'TOTS3.SA',
'TRPL4.SA',
'UGPA3.SA',
'USIM5.SA',
'VALE3.SA',
'VIVT4.SA',
'VVAR3.SA',
'WEGE3.SA',
'YDUQ3.SA']

data = yf.download(  # or pdr.get_data_yahoo(...
        # tickers list or string as well
        tickers = lista_acoes_tcc ,

        # use "period" instead of start/end
        # valid periods: 1d,5d,1mo,3mo,6mo,1y,2y,5y,10y,ytd,max
        # (optional, default is '1mo')
        #period = "1d",
    
        start="2015-01-01", end="2019-12-31",

        # fetch data by interval (including intraday if period < 60 days)
        # valid intervals: 1m,2m,5m,15m,30m,60m,90m,1h,1d,5d,1wk,1mo,3mo
        # (optional, default is '1d')
        #interval = "15m",

        # group by ticker (to access via data['SPY'])
        # (optional, default is 'column')
        group_by = 'column',

        # adjust all OHLC automatically
        # (optional, default is False)
        auto_adjust = True,

    
        # download pre/post regular market hours data
        # (optional, default is False)
        prepost = True,

        # use threads for mass downloading? (True/False/Integer)
        # (optional, default is True)
        threads = True,

        # proxy URL scheme use use when downloading?
        # (optional, default is None)
        proxy = None
    )


data = data[["Close"]]
data.columns = data.columns.droplevel(level=0)

data.columns = data.columns.str.replace('.SA','',regex=False)
data.rename(columns={'^BVSP':'IBOV'}, inplace=True)

data = data[data["IBOV"].notna()]

########data.to_csv('Analise.csv', index=True)  


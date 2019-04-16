#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCONFREC  ºAutor  ³Ricardo Rotta       º Data ³  10/24/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio do Palete para armazenagem                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RCONFREC(_cParam, dDataBase, cEmbarq, cPalete)

Local oReport

RCONFRECR3(_cParam, dDataBase, cEmbarq, cPalete)

//oReport := ReportDef(_cParam, dDataBase, cEmbarq, cPalete)
//oReport:PrintDialog()

Return

//-------------------------------------------------------------------------------------------
//
Static Function RCONFRECR3(_cParam, dDataBase, cEmbarq, cPalete)


LOCAL cDesc1 :="Este relatorio tem o objetivo de Imprimir os Paletes"
LOCAL cDesc2 :="referente a contagem realizada num Romaneio"
LOCAL cDesc3 := ""
LOCAL cString:="ZCZ"
Local cPerg := "RCONFREC"
Local _cCodUser := RetCodUsr()
Local aPerg		:= {}
Default _cParam := "0"

PRIVATE tamanho:="P"
PRIVATE limite :=80
PRIVATE cbCont,cabec1,cabec2,cbtxt
PRIVATE aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog:="RCONFRECR"
PRIVATE nLastKey := 0
PRIVATE li:=80, lRodape:=.F.
PRIVATE wnrel  := "RCONFREC"
PRIVATE titulo := "Paletes por Romaneio"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nTipo      := 18
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta perguntas no SX1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt   := SPACE(10)
cbcont  := 0
Li      := 80
m_pag   := 1

cabec1  := "IT  PRODUTO         DESCRICAO                       FORNEC  QTDE  ENDERECO"
cabec2  := ""
//          99  XXXxxxXXXxxxXXX XXXxxxXXXxxxXXXxxxXXXxxxX    XXXxxx   999999  XXXxxxXXXxxxXXX
//                    1         2         3         4         5         6         7         8         9        10        11        12        13        14
//          012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

Gera_SX1(cPerg)

If _cParam == "1"
	cQuery := " SELECT MIN(ZCZ_DATA) DATAINI, MAX(ZCZ_DATA) DATAFIM FROM " + RetSqlName("ZCZ")
	cQuery += " WHERE ZCZ_FILIAL = '" + xFilial("ZCZ") + "'"
	cQuery += " AND ZCZ_EMBARQ = '" + cEmbarq + "'"
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"XZC2",.F.,.F.)
	DbSelectArea("XZC2")	
	Pergunte(cPerg,.f., , , , , @aPerg)
	mv_par01 := Stod(XZC2->DATAINI)
	mv_par02 := Stod(XZC2->DATAFIM)
	mv_par03 := cEmbarq
	mv_par04 := cEmbarq
	mv_par05 := cPalete
	mv_par06 := cPalete
	mv_par07 := " "
	mv_par08 := "ZZZZZ"
	__SaveParam(cPerg,aPerg)
	XZC2->(DbCloseArea())
Else
	Pergunte(cPerg,.F.)
Endif
dbSelectArea("ZCZ")
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| RCONFREC_A(@lEnd,tamanho,titulo,wnRel,cString)},titulo)

//---------------------------------------------------------------------------------------------------

Static Function RCONFREC_A( lEnd, tamanho, titulo, wnRel )

Local cAlias1 	:= GetNextAlias()
Local _cCodUser := RetCodUsr()
Local nCntImpr  := 0
Local cRodaTxt	:= "Palete por Romaneio"
Local m_pag		:= 1
Local _lSetor	:= .F.
Local _cDescZon	:= ""
dbSelectArea("ZCZ")
dbSetOrder(1)

_cQuery := "SELECT * FROM " + RetSqlName("ZCZ") + " ZCZ"
_cQuery += " WHERE ZCZ_FILIAL = '" + xFilial("ZCZ") + "'"
_cQuery += " AND ZCZ_DATA >= '" + Dtos(mv_par01) + "'"
_cQuery += " AND ZCZ_DATA <= '" + Dtos(mv_par02) + "'"
_cQuery += " AND ZCZ_EMBARQ >= '" + mv_par03 + "'"
_cQuery += " AND ZCZ_EMBARQ <= '" + mv_par04 + "'"
_cQuery += " AND ZCZ_XPALET >= '" + mv_par05 + "'"
_cQuery += " AND ZCZ_XPALET <= '" + mv_par06 + "'"
_cQuery += " AND ZCZ_OPER >= '" + mv_par07 + "'"
_cQuery += " AND ZCZ_OPER <= '" + mv_par08 + "'"
_cQuery += " AND ZCZ.D_E_L_E_T_ = ' '"
_cQuery += " ORDER BY ZCZ_EMBARQ, ZCZ_XPALET, ZCZ_ENDER DESC, ZCZ_ITEM, ZCZ_PROD"
_cQuery := ChangeQuery(_cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAlias1,.F.,.F.)
DbSelectArea(cAlias1)
While !Eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o usuario interrompeu o relatorio                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAbortPrint
		@Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
		Exit
	Endif
	_cRomaneio := (cAlias1)->ZCZ_EMBARQ
	dbSelectArea("DCW")
	dbSetOrder(1)
	dbSeek(xFilial()+_cRomaneio)
	_lSetor := IIF(DCW->DCW_XSEPAR == "S",.T.,.F.)
	dbSelectArea("DCX")
	dbSetOrder(1)
	dbSeek(xFilial()+_cRomaneio)
	_cCodForn  := DCX->DCX_FORNEC
	_cLoja	   := DCX->DCX_LOJA
	_cNFor     := Posicione("SA2",1,xFilial("SA2")+_cCodForn+_cLoja,"A2_NREDUZ")
	While !(cAlias1)->(Eof()) .and. _cRomaneio == (cAlias1)->ZCZ_EMBARQ
		_cPalete := (cAlias1)->ZCZ_XPALET
		cTitulo := "Romaneio: "+ _cRomaneio + "      Palete: " + _cPalete
		If Li > 55
			Li := 0
			Cabec(cTitulo,Cabec1,Cabec2,wnRel,Tamanho,nTipo)
			m_pag++
		EndIf
		dbSelectArea("ZZL")
		dbSetOrder(1)
		dbSeek(xFilial()+_cRomaneio+_cPalete)
		If Empty(ZZL->ZZL_DTFECH)
			_cXConf  := " "
		Else
			_cXConf  := "S"
		Endif
		dbSelectArea(cAlias1)
		_cCOper  := (cAlias1)->ZCZ_OPER
		_cItem   := Replicate("0",TAMSX3("ZCZ_ITEM")[1])
		_lVez	 := .T.
		While !(cAlias1)->(Eof()) .and. _cRomaneio == (cAlias1)->ZCZ_EMBARQ .and. _cPalete == (cAlias1)->ZCZ_XPALET
			If lAbortPrint
				@Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
				Exit
			Endif
			If Li > 55
				Li := 0
				Cabec(cTitulo,Cabec1,Cabec2,wnRel,Tamanho,nTipo)
				m_pag++
			EndIf
			_cCodZon := ZCZ->ZCZ_CODZON
			_cItem := Soma1(_cItem)
			@ Li, 000 PSAY _cItem
			@ Li, 004 PSAY (cAlias1)->ZCZ_PROD
			@ Li, 020 PSAY Substr(Posicione("SB1",1,xFilial("SB1")+(cAlias1)->ZCZ_PROD,"B1_DESC"),1,31)
			@ Li, 049 PSAY Posicione("SB1",1,xFilial("SB1")+(cAlias1)->ZCZ_PROD,"B1_XMARCA")
			@ Li, 058 PSAY (cAlias1)->ZCZ_QTCONF Picture "@E 999999"
			@ Li, 066 PSAY IIF(!Empty((cAlias1)->ZCZ_ENDER), (cAlias1)->ZCZ_ENDER, "SEM LOCAL")
			Li++
			dbSelectArea("SZ8")
			dbSetOrder(1)
			If dbSeek(xFilial()+(cAlias1)->ZCZ_PROD+(cAlias1)->ZCZ_LOCAL)
				While !Eof() .and. xFilial()+(cAlias1)->ZCZ_PROD+(cAlias1)->ZCZ_LOCAL == SZ8->(Z8_FILIAL+Z8_CODPRO+Z8_LOCAL)
					If SZ8->Z8_ENDER <> (cAlias1)->ZCZ_ENDER
						@ Li, 066 PSAY (cAlias1)->ZCZ_ENDER
						Li++
					Endif
					dbSelectArea("SZ8")
					dbSkip()
				End
			Endif
			@ Li,00 PSAY Replicate('-',78)
			Li++
			nCntImpr++
			dbSelectArea(cAlias1)
			(cAlias1)->(dbSkip())
		End
		Li:=Li+3
		@ Li, 000 PSAY "ROMANEIO: " + _cRomaneio + "      PALLET: " + _cPalete + IIF(_lSetor, "   SETOR: " + Posicione("DC4",1,xFilial("DC4")+_cCodZon,"DC4_DESZON"), "")
		Li:=Li+1
		@ Li, 000 PSAY "Conferente: " + Posicione("DCD",1,xFilial("DCD")+_cCOper,"DCD_NOMFUN")
		Li:=Li+3
		If _cXConf == "S"
			@ Li, 000 PSAY "___________________________"
			Li++
			@ Li, 000 PSAY "           Repositor       "
		Else
			@ Li, 000 PSAY "Palete Nao Finalizado" 
		Endif
		Li := 70
	End
End

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnRel)
Endif

MS_FLUSH()

Return Nil
//-------------------------------------------------------------------
Static Function ImpCabec(_cRomaneio, _cPalete, m_pag )

Local cabec1  := "IT  PRODUTO         DESCRICAO                       FORNEC  QTDE  ENDERECO"

@Li ,00 PSAY SubStr(SM0->M0_FILIAL,1,20)
@Li ,25 PSAY "ROMANEIO : " + _cRomaneio
@Li ,70 PSAY " PAG.: " + Alltrim(Str(m_pag))
Li++
@Li ,25 PSAY "PALETE...: " + _cPalete
@Li ,68 PSAY dDataBase
Li++
@Li,00 PSAY Replicate("=",78)
Li++
@Li,00 PSAY cabec1
Li++
@Li,00 PSAY Replicate("=",78)
Li++
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Nereu Humberto Junior  ³ Data ³03.08.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(_cParam, _dData, cEmbarq, cPalete)

Local oReport 
Local oSection 
Local oCell         
//Local aOrdem    := {OemToAnsi("Data Registro"),OemToAnsi("Sequencia")}
Local cPerg := "RCONFREC"
Local cTamNome := TamSX3('A2_NREDUZ')[1]
Local cTamProd := TamSX3('B1_DESC')[1]
Local lQuery
Local lPageBreak := .T.
Local cAlias1 	:= GetNextAlias()
Local _cCodUser := RetCodUsr()
Default _cParam := "0"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta perguntas no SX1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Gera_SX1(cPerg)
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oReport := TReport():New("REGRMP","Registro Entrada Materia Prima",cPerg, {|oReport| ReportPrint(oReport,cPerg,cAlias1,cAlias2, aOrdem)},"Impressao do registro de entrada de materia-prima") //"Kardex por Localizacao (por produto)"##//"Este programa emitir  um Kardex com todas as movimenta‡”es"##//"do estoque por Localizacao e Numero de Serie, diariamente."

If _cParam == "1"
	cQuery := " SELECT MIN(ZCZ_DATA) DATAINI, MAX(ZCZ_DATA) DATAFIM FROM " + RetSqlName("ZCZ")
	cQuery += " WHERE ZCZ_FILIAL = '" + xFilial("ZCZ") + "'"
	cQuery += " AND ZCZ_EMBARQ = '" + cEmbarq + "'"
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"XZC2",.F.,.F.)
	DbSelectArea("XZC2")	
	mv_par01 := Stod(XZC2->DATAINI)
	mv_par02 := Stod(XZC2->DATAFIM)
	mv_par03 := cEmbarq
	mv_par04 := cEmbarq
	mv_par05 := cPalete
	mv_par06 := cPalete
	mv_par07 := _cCodUser
	mv_par08 := _cCodUser
	XZC2->(DbCloseArea())
	dbSelectArea("ZCZ")
	oReport := TReport():New("RCONFREC","Romaneio",, {|oReport| ReportPrint(oReport,cPerg,cAlias1)},"Paletes por Romaneio")
Else
	oReport := TReport():New("RCONFREC","Romaneio",cPerg, {|oReport| ReportPrint(oReport,cPerg,cAlias1)},"Paletes por Romaneio")
Endif
oReport:SetPortrait(.T.)
oReport:nFontBody := 10
oReport:nLineHeight := 45 // Define a altura da linha.
//oReport:SetLandscape()    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                        		³
//³ mv_par01         	// Produto ?	                        		³
//³ mv_par02        	// Lote ?		                        		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,"Romaneio",{"ZCZ"}) // "Movimentos por Endereco"
oSection1:PageBreak (lPageBreak)

//oSection1:SetHeaderPage()

TRCell():New(oSection1,"ZCZ_ITEM"	,cAlias1,/*Titulo*/	,/*Picture*/					,TAMSX3("ZCZ_ITEM")[1]	,/*lPixel*/)
TRCell():New(oSection1,"ZCZ_PROD"	,cAlias1,/*Titulo*/	,/*Picture*/					,TAMSX3("ZCZ_PROD")[1]	,/*lPixel*/)
TRCell():New(oSection1,"cNomProd"	," "	,"DESCRICAO",/*Picture*/					,TAMSX3("B1_DESC")[1]	,/*lPixel*/)
TRCell():New(oSection1,"cNomForn"	," "	,"FORNEC"	,/*Picture*/					,TAMSX3("A2_NREDUZ")[1]	,/*lPixel*/)
TRCell():New(oSection1,"ZCZ_QTCONF"	,cAlias1,"QUANT"	,PesqPict("ZCZ","ZCZ_QTCONF")	,TAMSX3("ZCZ_QTCONF")[1],/*lPixel*/)
TRCell():New(oSection1,"cEndere"	," "	,"ENDERECO"	,/*Picture*/					,TAMSX3("BE_LOCALIZ")[1],/*lPixel*/)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Nereu Humberto Junior  ³ Data ³03.08.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cPerg,cAlias1)

Local oSection1 := oReport:Section(1)
Local lFooter  	 := .T.														// Variavel para pular a pagina na quebra da secao 1
Local _aTotMP	:= {}
Local _aArea	:= GetArea()
Local _cDoc     := " "
Local _aTotMP 	:= {}
//Local _nOrdem   := oSection1:GetOrder()
Local _aTotDtP  := {}
Local _cTicket
Local _cPalete
Local _cXConf
Local _cCOper
Local lFirst := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatório                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("ZCZ")
dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cOrderBy := "% ZCZ_EMBARQ, ZCZ_XPALET, ZCZ_ITEM, ZCZ_PROD %"

BEGIN REPORT QUERY oSection1
	BeginSql Alias cAlias1
	SELECT *
	FROM %table:ZCZ% ZCZ
	WHERE ZCZ_FILIAL = %xFilial:ZCZ% AND 
		ZCZ_DATA >= %Exp:Dtos(mv_par01)% AND 
		ZCZ_DATA <= %Exp:Dtos(mv_par02)% AND 
		ZCZ_EMBARQ >= %Exp:mv_par03% AND 
		ZCZ_EMBARQ <= %Exp:mv_par04% AND 
		ZCZ_XPALET >= %Exp:mv_par05% AND 
		ZCZ_XPALET <= %Exp:mv_par06% AND 
		ZCZ_OPER >= %Exp:mv_par07% AND 
		ZCZ_OPER <= %Exp:mv_par08% AND 
		ZCZ.%notDel%
		ORDER BY %Exp:cOrderBy%
	EndSQL
END REPORT QUERY oSection1 	 

oReport:SetMeter((cAlias1)->(LastRec()))

While !oReport:Cancel() .And. !(cAlias1)->(Eof())
	_cRomaneio := (cAlias1)->ZCZ_EMBARQ
	dbSelectArea("DCX")
	dbSetOrder(1)
	dbSeek(xFilial()+_cRomaneio)
	_cCodForn  := DCX->DCX_FORNEC
	_cLoja	   := DCX->DCX_LOJA
	_cNFor     := Posicione("SA2",1,xFilial("SA2")+_cCodForn+_cLoja,"A2_NREDUZ")
	While !oReport:Cancel() .And. !(cAlias1)->(Eof()) .and. _cRomaneio == (cAlias1)->ZCZ_EMBARQ
		_cPalete := (cAlias1)->ZCZ_XPALET
		dbSelectArea("ZZL")
		dbSetOrder(1)
		dbSeek(xFilial()+_cRomaneio+_cPalete)
		If Empty(ZZL->ZZL_DTFECH)
			_cXConf  := " "
		Else
			_cXConf  := "S"
		Endif
		dbSelectArea(cAlias1)
		_cCOper  := (cAlias1)->ZCZ_OPER
		oReport:SetTitle("Romaneio: "+ _cRomaneio + " Palete: " + _cPalete)
		While !oReport:Cancel() .And. !(cAlias1)->(Eof()) .and. _cRomaneio == (cAlias1)->ZCZ_EMBARQ .and. _cPalete == (cAlias1)->ZCZ_XPALET
			lFirst := .T.
			oSection1:Init()
			If oReport:Cancel()
				Exit
			EndIf
			oSection1:Cell("cNomForn"):SetValue(_cNFor)
			oSection1:Cell("cNomProd"):SetValue(Posicione("SB1",1,xFilial("SB1")+(cAlias1)->ZCZ_PROD,"B1_DESC"))
			dbSelectArea("SZ8")
			dbSetOrder(1)
			If dbSeek(xFilial()+(cAlias1)->ZCZ_PROD+(cAlias1)->ZCZ_LOCAL)
				While !Eof() .and. xFilial()+(cAlias1)->ZCZ_PROD+(cAlias1)->ZCZ_LOCAL == SZ8->(Z8_FILIAL+Z8_CODPRO+Z8_LOCAL)
					oSection1:Cell("cEndere"):SetValue(SZ8->Z8_ENDER)
					If lFirst
						oSection1:Cell('ZCZ_ITEM'		):Show()
						oSection1:Cell('ZCZ_PROD'		):Show()
						oSection1:Cell('cNomProd'		):Show()
						oSection1:Cell('cNomForn'		):Show()
						oSection1:Cell('ZCZ_QTCONF'		):Show()
						oSection1:PrintLine()
						lFirst := .f.
					Else
						oSection1:Cell('ZCZ_ITEM'		):Hide()
						oSection1:Cell('ZCZ_PROD'		):Hide()
						oSection1:Cell('cNomProd'		):Hide()
						oSection1:Cell('cNomForn'		):Hide()
						oSection1:Cell('ZCZ_QTCONF'		):Hide()
						oSection1:PrintLine()
					Endif
					dbSelectArea("SZ8")
					dbSkip()
				End
			Else			
				oSection1:Cell("cEndere"):SetValue(" ")
				oSection1:PrintLine()
			Endif
			oReport:ThinLine()
			dbSelectArea(cAlias1)
			dbSkip()
		End
		oReport:SkipLine(1)
//		oReport:FatLine()
		oReport:SkipLine(1)
		oReport:SkipLine(1)
		oReport:SkipLine(1)
		oReport:PrintText( "ROMANEIO: " + _cRomaneio + "         PALLET: " + _cPalete + "     Conferente: " + Posicione("DCD",1,xFilial("DCD")+_cCOper,"DCD_NOMFUN"))
		oReport:SkipLine(1)
		oReport:SkipLine(1)
		oReport:SkipLine(1)
		If _cXConf == "S"
			oReport:PrintText( "___________________________" )
			oReport:PrintText( "           Repositor       " )	
		Else
			oReport:PrintText( "Palete Não Finalizado" )
		Endif
		oReport:EndPage() //-- Salta Pagina
	End
End
oSection1:Finish()
(cAlias1)->(DbCloseArea())
RestArea(_aArea)
Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Gera_SX1  ºAutor  ³Microsiga           º Data ³  07/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Gera_SX1(_cPerg)

Local _aArea := GetArea()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
_cPerg := PADR(_cPerg,10)

//-- Cria as perguntas.
aAdd(aRegs,{_cPerg,"01","Da Data       ?","","","mv_ch1","D",08,00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{_cPerg,"02","Ate Data      ?","","","mv_ch2","D",08,00,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{_cPerg,"03","Do Romaneio   ?","","","mv_ch3","C",06,00,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{_cPerg,"04","Ate Romaneio  ?","","","mv_ch4","C",06,00,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{_cPerg,"05","Do Palete     ?","","","mv_ch5","C",03,00,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{_cPerg,"06","Ate Palete    ?","","","mv_ch6","C",03,00,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{_cPerg,"07","Do Conferente ?","","","mv_ch7","C",06,00,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","DCD1"})
aAdd(aRegs,{_cPerg,"08","Ate Conferente?","","","mv_ch8","C",06,00,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","DCD1"})
For i:=1 to Len(aRegs)
	If !dbSeek(_cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next      
RestArea(_aArea)
Return
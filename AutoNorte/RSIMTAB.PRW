#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RSIMTAB   ºAutor  ³Ricardo Rotta       º Data ³  09/24/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de comparação da tabela de preço                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RSIMTAB

	Local oReport

	oReport := ReportDef()
	oReport:PrintDialog()

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
Static Function ReportDef()

	Local oReport
	Local oSection
	Local oCell
	Local aOrdem    := {OemToAnsi("Referencia"),OemToAnsi("Codigo")}
	Local cPerg := "RSIMTAB"
	Local lPageBreak := .T.

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
	oReport := TReport():New("RSIMTAB","Variação de Preços",cPerg, {|oReport| ReportPrint(oReport,cPerg, aOrdem)},"Relatório de comparação da lista de preço")
	oReport:SetPortrait(.T.)
	//oReport:SetLandscape()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                        		³
	//³ mv_par01         	// Produto ?	                        		³
	//³ mv_par02        	// Lote ?		                        		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1 := TRSection():New(oReport,"Tabela de Preço Fornecedor",{"SZ2","SA2"}, aOrdem) // "Movimentos por Endereco"
	oSection1:PageBreak (lPageBreak)
	oSection1:SetHeaderPage()

	TRCell():New(oSection1,"Z2_CODTAB"	,"SZ2",/*Titulo*/	,/*Picture*/					,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"Z2_DATA"	,"SZ2",/*Titulo*/	,/*Picture*/					,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"Z2_DESCTAB"	,"SZ2",/*Titulo*/	,/*Picture*/					,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"Z2_MARCA"	,"SZ2",/*Titulo*/	,/*Picture*/					,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"Z2_OBS"		,"SZ2",/*Titulo*/	,/*Picture*/					,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	oSection2 := TRSection():New(oSection1,"Itens da Tabela de Preço",{"SZ3"})
	TRCell():New(oSection2,"Z3_CODREF"	,"SZ3",/*Titulo*/	,/*Picture*/					,TamSX3("Z3_CODREF")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"Z3_COD"		,"SZ3",/*Titulo*/	,/*Picture*/					,TamSX3("Z3_COD")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"B1_DESC"	,"SB1",/*Titulo*/	,/*Picture*/					,TamSX3("B1_DESC")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"Z3_PRCANT"	,"SZ3","Prc. Ant."	,PesqPict("SZ3","Z3_PRCLIQ")	,TamSX3("Z3_PRCLIQ")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"Z3_PRCREP"	,"SZ3",/*Titulo*/	,PesqPict("SZ3","Z3_PRCREP")	,TamSX3("Z3_PRCREP")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"Z3_LETRA"	,"SZ3","TP"		,"@!"							,1						,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"Z3_MARGEM"	,"SZ3","Margem %"	,"@E 9,999.99"					,10						,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"Z3_FATOR"	,"SZ3",/*Titulo*/	,/*Picture*/					,TamSX3("Z3_FATOR")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"Z3_PRCBRT"	,"SZ3",/*Titulo*/	,PesqPict("SZ3","Z3_PRCBRT")	,TamSX3("Z3_PRCBRT")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"Z3_DESCONT"	,"SZ3",/*Titulo*/	,PesqPict("SZ3","Z3_DESCONT")	,TamSX3("Z3_DESCONT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"Z3_PRCLIQ"	,"SZ3",/*Titulo*/	,PesqPict("SZ3","Z3_PRCLIQ")	,TamSX3("Z3_PRCLIQ")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"Z3_VARIAC"	,"SZ3","Variação %"	,"@E 9,999.99"					,10						,/*lPixel*/,/*{|| code-block de impressao }*/)
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
Static Function ReportPrint(oReport,cPerg, aOrdem)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(1):Section(1)
	Local nOrdem	:= oSection1:GetOrder()
	Local lFooter  	 := .T.														// Variavel para pular a pagina na quebra da secao 1
	Local _aArea	:= GetArea()
	Local _cCodTab	:= mv_par01
	Local _nPrcLiq 	:= 0
	Local _nVar	 	:= 0
	Local _nMargem 	:= 0
	Local cCodDA0	:= Alltrim(SuperGetMv("AN_TABPRC",.F.,"100"))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtragem do relatório                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZ2")
	dbSetOrder(1)
	If dbSeek(xFilial()+_cCodTab)
		oSection1:Init()
		oSection1:PrintLine()
		//	oReport:SetTitle("Registro de Matéria Prima (Acerola) - RG-PR-006 - REV 01 - Documento: "+ (cAlias1)->Z2_DOC )
		_cCodForn := SZ2->Z2_CODFORN
		_cLjForn  := SZ2->Z2_LOJA
		dbSelectArea("SZ3")
		If nOrdem == 1
			dbSetOrder(1)
		Else
			dbSetOrder(3)
		Endif
		If dbSeek(xFilial()+_cCodTab)
			oReport:SkipLine(2)
			oReport:ThinLine()
			oSection2:Init()
			While !oReport:Cancel() .And. !Eof() .and. xFilial("SZ3")+_cCodTab == SZ3->(Z3_FILIAL+Z3_CODTAB)
				If oReport:Cancel()
					Exit
				EndIf
				If !Empty(SZ3->Z3_COD)
					If SB1->(MsSeek(xFilial('SB1')+SZ3->Z3_COD))
						oSection2:Cell("B1_DESC"   ):setValue(SB1->B1_DESC)
					EndIf

					_nPrcAtu 	:= 0
					cLetra 		:= ""
					nFator		:= 0
					nDesc		:= 0
					dbSelectArea("DA1")
					DbSelectArea("DA1")
					DA1->(DbOrderNickName("DA1SEQ"))//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_XTABSQ
					If DA1->(DbSeek(xFilial("SZ3")+cCodDA0+SZ3->Z3_COD))
						While !DA1->(Eof()) .And. xFilial("SZ3")+cCodDA0+SZ3->Z3_COD == DA1->DA1_FILIAL+DA1->DA1_CODTAB+DA1->DA1_CODPRO
							If DA1->DA1_DATVIG <= dDataBase// .and. (Empty(DA1->DA1_DATVIG) .or. DA1->DA1_DATVIG >= dDataBase)
								_nPrcAtu 	:= DA1->DA1_PRCVEN
								cLetra		:= DA1->DA1_XLETRA
								nFator		:= DA1->DA1_XFATOR
								nDesc		:= DA1->DA1_XDESCV
								Exit
							Endif
							DA1->(dbSkip())
						End
					EndIf

					_nPrcLiq := SZ3->Z3_PRCLIQ
					_nVar	 := Round(((_nPrcLiq - _nPrcAtu) / _nPrcAtu)*100,2)
					_nMargem := 0
					oSection2:Cell("Z3_PRCANT"   ):setValue(_nPrcAtu)
					oSection2:Cell("Z3_LETRA"   ):setValue(cLetra)
					oSection2:Cell("Z3_FATOR"   ):setValue(nFator)
					oSection2:Cell("Z3_VARIAC"   ):setValue(_nVar)
					oSection2:Cell("Z3_DESCONT"   ):setValue(nDesc)
					If nFator >= MV_PAR02 .And. nFator <= MV_PAR03
						SZ3->(DbSkip())
						Loop
					EndIf
					oSection2:PrintLine()
				Endif
				dbSelectArea("SZ3")
				SZ3->(DbSkip())
			End
			oSection2:Finish()
		Endif
		osection1:SetPageBreak(.T.)
		oSection1:Finish()
	Endif
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
	aAdd(aRegs,{_cPerg,"01","Tabela      ?","","","mv_ch1","C",03,00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"02","Variação de  ?","","","mv_ch2","N",10,02,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"03","Variação ate ?","","","mv_ch3","N",10,02,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
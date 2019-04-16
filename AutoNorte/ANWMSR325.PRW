#INCLUDE "WMSR325.CH"
#INCLUDE "TOTVS.CH"

//---------------------------------------------------------------------------
/*/{Protheus.doc} WMSR325
Relatorio checagem embarque conferencia
@author Alexsander Burigo Corrêa
@since 20/08/2012
@version 1.0
@history 28/03/2019, Feipe Caiado, Adequação para impressora matricial
/*/
//---------------------------------------------------------------------------

User Function ANWMSR325(nTipo)
	Local oReport  // objeto que contem o relatorio
	Local aAreaDCW 	:= DCW->( GetArea() )
	Local aAreaDCX 	:= DCX->( GetArea() )
	Local aAreaDCY 	:= DCY->( GetArea() )
	Local aAreaDCZ 	:= DCZ->( GetArea() )
	Local cDesc1 	:="Este relatorio tem o objetivo de Imprimir a Conferência"
	Local cDesc2 	:="referente a contagem realizada num Romaneio"
	Local cDesc3 	:= ""
	Local cString	:="ZCZ"
	Local cPerg	  	:= "ANWMSR325"

	Private cTamanho:="P"
	Private aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
	Private nomeprog:="WMSR325"
	Private nLastKey:= 0
	Private Li	:=80
	Private wnrel  	:= "WMSR325"
	Private titulo 	:= STR0001
	Private nTipoRel:= 18

	Default nTipo:= 1

	//  Interface de impressao
	If nTipo == 1
		oReport := ReportDef()
		oReport:PrintDialog()
	Else
		Pergunte(cPerg,.F.)
		wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,cTamanho)

		If nLastKey == 27
			Return
		Endif

		SetDefault(aReturn,cString)

		If nLastKey == 27
			Return
		Endif

		RptStatus({|lEnd| AN001(@lEnd,cTamanho,titulo,wnRel,cString)},titulo)

	EndIf

	RestArea( aAreaDCW )
	RestArea( aAreaDCX )
	RestArea( aAreaDCY )
	RestArea( aAreaDCZ )
Return

//-----------------------------------------------------
/*/{Protheus.doc} AN001
Impressão Relatório Matricial
@author felipe.caiado
@since 28/03/2019
@version 1.0

@type function
/*/
//-----------------------------------------------------
Static Function AN001(lEnd, cTamanho, titulo, wnRel)

	Local aProdDif 	:= {}
	Local nJ		:= 0
	Local aPaltDif	:= {}
	Private m_pag 	:= 1

	Li := 0
	Cabec(titulo,"","",wnRel,cTamanho,nTipoRel)
	m_pag++

	//          1         2         3         4         5         6         7         8
	//012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//Romaneio:
	//Situacao:
	//
	//Documento  Serie  Fornecedor  Loja  Razao Social
	//xxxxxxxxx  xxx    xxxxxx      xx    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	//Prd. Origem     Descricao                      UM  Qt NF  Qt Conf.  Diferenca


	@ Li, 000 PSAY "Romaneio: " + DCW->DCW_EMBARQ
	Li ++
	@ Li, 000 PSAY "Situacao: " + X3Combo("DCW_SITEMB",DCW->DCW_SITEMB)
	Li ++
	Li ++

	//Documento  Serie  Fornecedor  Loja  Razao Social
	//xxxxxxxxx  xxx    xxxxxx      xx    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	@ Li, 000 PSAY "Documento  Serie  Fornecedor  Loja  Razao Social"
	Li ++
	@ Li, 000 PSAY Replicate("-",80)
	Li ++

	dbSelectArea('DCX')
	DCX->( dbSetOrder(1))
	DCX->( dbSeek(xFilial('DCX')+DCW->DCW_EMBARQ) )
	While !DCX->( Eof() ) .And. DCX->DCX_FILIAL+DCX->DCX_EMBARQ == xFilial('DCX')+DCW->DCW_EMBARQ

		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial("SA2")+DCX->DCX_FORNEC+DCX->DCX_LOJA))

		@ Li, 000 PSAY DCX->DCX_DOC
		@ Li, 011 PSAY DCX->DCX_SERIE
		@ Li, 018 PSAY DCX->DCX_FORNEC
		@ Li, 030 PSAY DCX->DCX_LOJA
		@ Li, 036 PSAY SA2->A2_NOME

		Li ++

		DCX->( dbSkip() )

	EndDo

	Li ++
	@ Li, 000 PSAY "Resumo das contagens por Produto"
	Li ++
	Li ++
	//Prd. Origem     Descricao                      UM  Qt NF  Qt Conf.  Diferenca
	@ Li, 000 PSAY "Prd. Origem     Descricao                      UM  Qt NF  Qt Conf.  Difer."
	Li ++
	@ Li, 000 PSAY Replicate("-",80)
	Li ++

	DCY->( dbSetOrder(2))
	DCY->( dbSeek(xFilial('DCY')+DCW->DCW_EMBARQ) )
	While !DCY->( Eof() ) .And. DCY->DCY_FILIAL+DCY->DCY_EMBARQ == xFilial('DCY')+DCW->DCW_EMBARQ

		If Li > 55
			Li := 0
			Cabec(titulo,"","",wnRel,cTamanho,nTipoRel)
			m_pag++

			@ Li, 000 PSAY "Prd. Origem     Descricao                      UM  Qt NF  Qt Conf.  Difer."
			Li ++
			@ Li, 000 PSAY Replicate("-",80)
			Li ++

		EndIf

		cProdOri := DCY->DCY_PRDORI

		DbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cProdOri))

		cDescri  	:= SB1->B1_DESC
		cUM	  		:= SB1->B1_UM
		nQtdConf 	:= 0
		nQtdOri  	:= 0

		While !DCY->( Eof() ) .And. DCY->DCY_FILIAL+DCY->DCY_EMBARQ == xFilial('DCY')+DCW->DCW_EMBARQ .and. cProdOri == DCY->DCY_PRDORI

			nQtdConf+= DCY->DCY_QTCONF
			nQtdOri += DCY->DCY_QTORIG

			DCY->(dbSkip())

		EndDo

		nDif := nQtdConf - nQtdOri

		If nDif <> 0

			aAdd(aProdDif, cProdOri)

		Endif

		If mv_par03 == 1
			If nDif == 0
				Loop
			Else
				@ Li, 000 PSAY cProdOri
				@ Li, 016 PSAY cDescri
				@ Li, 048 PSAY cUM
				@ Li, 052 PSAY Transform(nQtdOri,"@E 9,999")
				@ Li, 059 PSAY Transform(nQtdConf,"@E 999,999")
				@ Li, 069 PSAY Transform(nDif,"@E 99,999")
				Li ++
			Endif
		Else
			@ Li, 000 PSAY cProdOri
			@ Li, 016 PSAY cDescri
			@ Li, 048 PSAY cUM
			@ Li, 052 PSAY Transform(nQtdOri,"@E 9,999")
			@ Li, 059 PSAY Transform(nQtdConf,"@E 999,999")
			@ Li, 069 PSAY Transform(nDif,"@E 99,999")
			Li ++
		EndIf

	EndDo

	Li ++
	@ Li, 000 PSAY "Produtos com Diferenças e seus Respectivos Paletes"
	Li ++
	Li ++
	//          1         2         3         4         5         6         7         8
	//012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//Palet  Produto         Descricao                       Qt.Conf  Operador
	@ Li, 000 PSAY "Palet  Produto         Descricao                       Qt.Conf  Operador"
	Li ++
	@ Li, 000 PSAY Replicate("-",80)
	Li ++

	If Len(aProdDif) > 0
		For nJ:=1 to Len(aProdDif)
			dbSelectArea("ZCZ")
			ZCZ->(dbSetOrder(3))
			ZCZ->(dbSeek(xFilial()+DCW->DCW_EMBARQ+aProdDif[nJ]))
			While !ZCZ->(Eof()) .and. xFilial("ZCZ")+DCW->DCW_EMBARQ+aProdDif[nJ] == ZCZ->(ZCZ_FILIAL+ZCZ_EMBARQ+ZCZ_PROD)
				aadd(aPaltDif, {ZCZ->ZCZ_XPALET, ZCZ->ZCZ_PROD, Posicione("SB1",1,xFilial("SB1")+ZCZ->ZCZ_PROD,"B1_DESC"), ZCZ->ZCZ_QTCONF, ZCZ->ZCZ_OPER, Posicione("DCD",1,xFilial("DCD")+ZCZ->ZCZ_OPER,"DCD_NOMFUN")})
				ZCZ->(dbSkip())
			End
		Next nJ

		nJ := 0
		aPaltDif := ASort(aPaltDif,,, { | x,y | x[1]+x[2] > y[1]+y[2] })

		For nJ:=1 to Len(aPaltDif)

			If Li > 55
				Li := 0
				Cabec(titulo,"","",wnRel,cTamanho,nTipoRel)
				m_pag++

				@ Li, 000 PSAY "Palet  Produto         Descricao                       Qt.Conf  Operador"
				Li ++
				@ Li, 000 PSAY Replicate("-",80)
				Li ++

			EndIf


			@ Li, 000 PSAY aPaltDif[nJ,1]
			@ Li, 007 PSAY aPaltDif[nJ,2]
			@ Li, 023 PSAY aPaltDif[nJ,3]
			@ Li, 057 PSAY Transform(aPaltDif[nJ,4],"@E 99,999")
			@ Li, 065 PSAY Alltrim(aPaltDif[nJ,6])
			Li ++

		Next nJ
	Else
		@ Li, 000 PSAY "Não há Itens"
	Endif

	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnRel)
	Endif

	MS_FLUSH()

Return()
//----------------------------------------------------------
// Definições do relatório
//----------------------------------------------------------
Static Function ReportDef()
	Local oReport, oSection1, oSection2
	Local cEmbarq := DCW->DCW_EMBARQ
	Local cPerg	  := "ANWMSR325"
	Gera_SX1(cPerg)
	//-----------------------------------------------------------------------
	// Criacao do componente de impressao
	// TReport():New
	// ExpC1 : Nome do relatorio
	// ExpC2 : Titulo
	// ExpC3 : Pergunte
	// ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
	// ExpC5 : Descricao
	//-----------------------------------------------------------------------
	oReport:= TReport():New("WMSR325",'CHECK-OUT '+STR0001,cPerg, {|oReport| ReportPrint(oReport)},STR0001) // CHECK-OUT conferencia
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	oReport:nFontBody	:= 12 // Define o tamanho da fonte.
	oReport:nLineHeight	:= 50 // Define a altura da linha.

	//Verifica os parâmetros selecionados via Pergunte
	Pergunte(oReport:GetParam(),.F.)

	oSection1 := TRSection():New(oReport,"",{"DCW"})
	oSection1:SetLineStyle()
	oSection1:SetCols(1)
	TRCell():New(oSection1,"DCW_EMBARQ","DCW")
	TRCell():New(oSection1,"DCW_SITEMB","DCW")

	oSection2 := TRSection():New(oReport,"",{"DCX"})
	TRCell():New(oSection2,"DCX_DOC","DCX")
	TRCell():New(oSection2,"DCX_SERIE","DCX")
	TRCell():New(oSection2,"DCX_FORNEC","DCX")
	TRCell():New(oSection2,"DCX_LOJA","DCX")
	TRCell():New(oSection2,"A2_NOME","SA2")

	oSection3 := TRSection():New(oReport,"",{"DCY","SB1"})
	TRCell():New(oSection3,"DCY_PRDORI","DCY")
	TRCell():New(oSection3,'B1_DESC' 	,'SB1',/*Titulo*/,/*Picture*/,30		,/*lPixel*/, /*{|| Substr(SB1->B1_DESC,1,30) }*/)
	TRCell():New(oSection3,"B1_UM","SB1", "UM")
	TRCell():New(oSection3,"DCY_QTORIG"  ,"DCY"	   ,"Qt NF" ,"@E 999,999",6,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"DCY_QTCONF" ,"DCY"	   ,"Qt Conf." ,"@E 999,999",6,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"NQTDIFERE","DCY","Diferenca" ,"@E 999,999",6,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"LACUNA2"   ,/*Alias*/, STR0004  ,/*Picture*/, 30 ,/*lPixel*/,{|| "______________________________"}  )  //"Quantidade"
	TRPosition():New(oSection3,"SB1",1,{|| xFilial("SB1")+DCY->DCY_PROD})

	oSection4 := TRSection():New(oReport,"",{"ZCZ","DCD","SB1"})
	TRCell():New(oSection4,"ZCZ_XPALET"  ,"ZCZ")
	TRCell():New(oSection4,"ZCZ_PROD"    ,"ZCZ",/*Titulo*/,/*Picture*/,18		,/*lPixel*/, /*{|| Substr(SB1->B1_DESC,1,30) }*/)
	TRCell():New(oSection4,'B1_DESC' 	,'SB1',/*Titulo*/,/*Picture*/,30		,/*lPixel*/, /*{|| Substr(SB1->B1_DESC,1,30) }*/)
	TRCell():New(oSection4,"ZCZ_QTCONF"  ,"ZCZ"	   , ,"@E 999,999",6,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection4,"ZCZ_OPER"    ,"ZCZ")
	TRCell():New(oSection4,"DCD_NOMFUN"  ,"DCD")
	TRPosition():New(oSection4,"SB1",1,{|| xFilial("SB1")+ZCZ->ZCZ_PROD})
	TRPosition():New(oSection4,"DCD",1,{|| xFilial("DCD")+ZCZ->ZCZ_OPER})

Return(oReport)
//----------------------------------------------------------
// Impressão do relatório
//----------------------------------------------------------
Static Function ReportPrint(oReport)
	Local oSection1  := oReport:Section(1)
	Local oSection2  := oReport:Section(2)
	Local oSection3  := oReport:Section(3)
	Local oSection4  := oReport:Section(4)
	//Local oSection5  := oReport:Section(5)
	Local _aProdDif  := {}
	Local _aPaltDif  := {}
	If	MV_PAR01 == 2 .Or. MV_PAR02 == 2
		oSection3:SetLineBreak()
	Endif

	//	If	MV_PAR01 == 2 //Imprimir Lote? Nao
	////		oSection3:Cell("DCY_LOTE"):Disable()
	////		oSection3:Cell("DCY_SUBLOT"):Disable()
	//	Else
	//		oSection3:Cell("LACUNA1"):Disable()
	//	EndIf

	If	MV_PAR02 == 2 //Imprimir Quantidades ? Nao
		oSection3:Cell("DCY_QTORIG"):Disable()
		oSection3:Cell("DCY_QTCONF"):Disable()
		oSection3:Cell("NQTDIFERE"):Disable()
	Else
		oSection3:Cell("LACUNA2"):Disable()
	EndIf

	oReport:SetMeter(DCW->( LastRec() ))
	// Secção 1
	oSection1:Init()
	oSection1:PrintLine()
	oSection1:Finish()
	// Secção 2
	oSection2:Init()
	dbSelectArea('DCX')
	DCX->( dbSetOrder(1))
	DCX->( dbSeek(xFilial('DCX')+DCW->DCW_EMBARQ) )
	While !DCX->( Eof() ) .And. DCX->DCX_FILIAL+DCX->DCX_EMBARQ == xFilial('DCX')+DCW->DCW_EMBARQ
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial("SA2")+DCX->DCX_FORNEC+DCX->DCX_LOJA))
		oSection2:PrintLine()
		DCX->( dbSkip() )
	EndDo
	oSection2:Finish()
	// Secção 3
	oSection3:Init()
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText("Resumo das contagens por Produto")
	_aProdDif := {}
	dbSelectArea('DCY')
	DCY->( dbSetOrder(2))
	DCY->( dbSeek(xFilial('DCY')+DCW->DCW_EMBARQ) )
	While !DCY->( Eof() ) .And. DCY->DCY_FILIAL+DCY->DCY_EMBARQ == xFilial('DCY')+DCW->DCW_EMBARQ
		_cProdOri := DCY->DCY_PRDORI
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+_cProdOri))
		_cDescri  := SB1->B1_DESC
		_cUM	  := SB1->B1_UM
		_nQtdConf := 0
		_nQtdOri  := 0
		While !DCY->( Eof() ) .And. DCY->DCY_FILIAL+DCY->DCY_EMBARQ == xFilial('DCY')+DCW->DCW_EMBARQ .and. _cProdOri == DCY->DCY_PRDORI
			_nQtdConf+= DCY->DCY_QTCONF
			_nQtdOri += DCY->DCY_QTORIG
			dbSkip()
		End
		_nDif := _nQtdConf - _nQtdOri
		oSection3:Cell("B1_DESC"):SetValue(_cDescri)
		oSection3:Cell("B1_UM"):SetValue(_cUM)
		oSection3:Cell("DCY_PRDORI"):SetValue(_cProdOri)
		oSection3:Cell("DCY_QTORIG"):SetValue(_nQtdOri)
		oSection3:Cell("DCY_QTCONF"):SetValue(_nQtdConf)
		oSection3:Cell("NQTDIFERE"):SetValue(_nDif)
		If _nDif # 0
			aadd(_aProdDif, _cProdOri)
		Endif
		If mv_par03 == 1
			If _nDif == 0
				Loop
			Endif
		EndIf
		oSection3:PrintLine()
	EndDo
	oSection3:Finish()
	If Len(_aProdDif) > 0
		oSection4:Init()
		oReport:SkipLine()
		oReport:SkipLine()
		oReport:PrintText("Produtos com Diferenças e seus Respectivos Paletes")
		For nJ:=1 to Len(_aProdDif)
			dbSelectArea("ZCZ")
			dbSetOrder(3)
			dbSeek(xFilial()+DCW->DCW_EMBARQ+_aProdDif[nJ])
			While !Eof() .and. xFilial("ZCZ")+DCW->DCW_EMBARQ+_aProdDif[nJ] == ZCZ->(ZCZ_FILIAL+ZCZ_EMBARQ+ZCZ_PROD)
				aadd(_aPaltDif, {ZCZ->ZCZ_XPALET, ZCZ->ZCZ_PROD, Posicione("SB1",1,xFilial("SB1")+ZCZ->ZCZ_PROD,"B1_DESC"), ZCZ->ZCZ_QTCONF, ZCZ->ZCZ_OPER, Posicione("DCD",1,xFilial("DCD")+ZCZ->ZCZ_OPER,"DCD_NOMFUN")})
				dbSkip()
			End
		Next
		_aPaltDif := ASort(_aPaltDif,,, { | x,y | x[1]+x[2] > y[1]+y[2] })
		For nJ:=1 to Len(_aPaltDif)
			oSection4:Cell("ZCZ_XPALET"):SetValue(_aPaltDif[nJ,1])
			oSection4:Cell("ZCZ_PROD"):SetValue(_aPaltDif[nJ,2])
			oSection4:Cell("B1_DESC"):SetValue(_aPaltDif[nJ,3])
			oSection4:Cell("ZCZ_QTCONF"):SetValue(_aPaltDif[nJ,4])
			oSection4:Cell("ZCZ_OPER"):SetValue(_aPaltDif[nJ,5])
			oSection4:Cell("DCD_NOMFUN"):SetValue(_aPaltDif[nJ,6])
			oSection4:PrintLine()
		Next
	Else
		oReport:SkipLine()
		oReport:SkipLine()
		oReport:PrintText("Não há itens")
	Endif
	oReport:IncMeter()
Return
//-----------------------------------------------------------------
//
Static Function Gera_SX1(cPerg)

	Local i := 0
	Local j := 0
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}
	AADD(aRegs,{cPerg,"01","Imprimir Lote ?"       ,"","","mv_ch1","N",01,0,0,"C","","mv_par01","Sim","Si","Yes","","","Nâo","No","No","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Imprimir Quantidades ?","","","mv_ch2","N",01,0,0,"C","","mv_par02","Sim","Si","Yes","","","Nâo","No","No","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Apenas Com Diferença ?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Sim","Si","Yes","","","Nâo","No","No","","","","","","","","","","","","","","","","",""})
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
Return
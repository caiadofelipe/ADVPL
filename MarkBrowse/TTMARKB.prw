#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------
/*/{Protheus.doc} TTMARKB
MarkBrowse Din�mico
@author Felipe Caiado
@since 24/05/2019
@version 1.0
@param aCampos, array, Campos do MarkBrowse
@param aDados, array, Valores do MarkBrowse
@param aDados, logical, Campo Totalizador?
@param aDados, char, Cmpo do Totalizado
@param aDados, char, Marcado?

@type Function
/*/
//-----------------------------------------------------------
User Function TTMARKB(aCampos, aDados, lCmpTot, cCmpTot, lMarcado)

	Local aSize as array
	Local aObjects as array
	Local oDlgBrw as object
	Local cAliasBrw as character
	Local aField as array
	Local nX as numeric
	Local aRet as array
	Private cMark as character
	Private oTotSel as Object
	Private nTotSel as numeric
	Private oQtdSel as Object
	Private nQtdSel as numeric

	Default aCampos := {}
	Default aDados := {}
	Default lCmpTot := .F.
	Default cCmpTot := ""
	Default lMarcado := .T.

	//Verifica o campo totalizado
	If lCmpTot .And. Empty(cCmpTot)
		Alert("Par�metro do campo do total inv�lido")
		Return()
	EndIf

	//Verifica se os campos do MarkBrowse foram passados como par�metros
	If Len(aCampos) == 0
		Alert("Campos do MarkBrowse inexistentes")
		Return()
	EndIf

	//Verifica se os dados do MarkBrowse foram passados como par�metros
	If Len(aDados) == 0
		Alert("Dados do MarkBrowse inexistentes")
		Return()
	EndIf

	nX := 0
	cMark := GetMark()
	nTotSel := 0
	nQtdSel := 0
	cAliasBrw := GetNextAlias()
	aRer := {}
	aField := {}

	//Defini��o do campo MARK
	aAdd( aField, { "MARK"		, "C", 002, 0, "Mark",, .F., "" } )

	//Defini��o dos campos conforme par�metro
	For nX:=1 To Len(aCampos)
		aAdd(aField, aCampos[nX])
	Next nX

	aObjects := {}
	AAdd( aObjects, { 100, 30, .T., .F., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T., .F. } )
	aSize := MsAdvSize( .T. ) //Parametros verifica se exist enchoice

	//Cria Arquivo Tempor�rio
	oTempTable := FWTemporaryTable():New( cAliasBrw )

	//Seta os campos
	oTemptable:SetFields( aField )

	//Cria a tabela tempor�ria
	oTempTable:Create()

	//Ajusta as colunas para o FWMarkBrowse
	aColumn := FGetColumn( aField )

	//Alimenta a tabela tempor�ria do FWMarkBrose
	CrgMarkB(@cAliasBrw, aCampos, aDados)

	Define MsDialog oDlgBrw FROM aSize[7],00 To aSize[6],aSize[5] Title "MarkBrowse" Pixel

	// Cria o conteiner onde ser�o colocados os paineis
	oTela     := FWFormContainer():New( oDlgBrw )
	cIdTela	  := oTela:CreateHorizontalBox( 10 )
	cIdRod	  := oTela:CreateHorizontalBox( 80 )

	oTela:Activate( oDlgBrw, .F. )

	//Cria os paineis onde serao colocados os browses
	oPanelUp  	:= oTela:GeTPanel( cIdTela )
	oPanelDown  := oTela:GeTPanel( cIdRod )

	oBrowse := FWMarkBrowse():New()
	oBrowse:SetColumns( aColumn )
	oBrowse:SetOwner( oPanelDown )
	oBrowse:SetDataTable()
	oBrowse:SetAlias( cAliasBrw )
	oBrowse:SetDescription("MarkBrowse")
	oBrowse:SetMenuDef( "" )
	oBrowse:SetWalkThru( .F. )
	oBrowse:SetAmbiente( .F. )
	oBrowse:DisableReport()
	oBrowse:DisableConfig()
	oBrowse:DisableFilter()
	oBrowse:SetFieldMark( "MARK" )
	oBrowse:SetAllMark( { || FMarkAll( oBrowse, lCmpTot, cCmpTot ) } )
	oBrowse:bMark := {|| FMArkOne(oBrowse, lCmpTot, cCmpTot )}

	oBrowse:Activate()

	//Quantidade Selecionado
	@ oPanelUp:nTop + 10, oPanelUp:nLeft + 10 	SAY   "Quantidade Selecionada" SIZE 038,007 OF oPanelUp PIXEL
	@ oPanelUp:nTop + 18, oPanelUp:nLeft + 10	MSGET oQtdSel Var nQtdSel SIZE 080,015	OF oPanelUp PIXEL WHEN .F. PICTURE "@E 999,999,999" HASBUTTON

	//Verifica se existe o campo de Total
	If lCmpTot
		//Total Selecionado
		@ 010, 110 	SAY   "Total Selecionado" SIZE 038,007 OF oPanelUp PIXEL
		@ 018, 110 	MSGET oTotSel Var nTotSel SIZE 080,015	OF oPanelUp PIXEL WHEN .F. PICTURE "@E 999,999,999.99" HASBUTTON
	EndIf

	//Verifica se j� traz o MarkBrowse Selecionado
	If lMarcado
		FMarkAll( oBrowse, lCmpTot, cCmpTot )
	EndIf

	ACTIVATE MSDIALOG oDlgBrw CENTERED ON INIT (EnchoiceBar(oDlgBrw,{||FwMsgRun(Nil,{||ExecBlock("TTMARKEX",.F.,.F.,{cAliasBrw}) },Nil,"Aguarde, Atualizando Dados"),oDlgBrw:End()},{||oDlgBrw:End()},,))

	//Exclui a tabela tempor�ria
	oTempTable:Delete()

Return()

/*/{Protheus.doc} FGetColumn
Altera��o das colunas do FWMARKBROWSE
@author Felipe Caiado
@since 24/05/2019
@version 1.0
@type Function
/*/
Static Function FGetColumn( aStruct )

	Local cCombo		as character
	Local nPos			as numeric
	Local nI			as numeric
	Local aColumns		as array
	Local aCombo		as array

	cCombo		:=	""
	nPos		:=	0
	nI			:=	0
	aColumns	:=	{}
	aCombo		:=	{}

	//Alimenta array com as colunas
	For nI := 1 to Len( aStruct )
		If aStruct[nI,7]

			nPos ++

			aAdd( aColumns, FWBrwColumn():New() )

			aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
			aColumns[nPos]:SetTitle( aStruct[nI,5] )
			aColumns[nPos]:SetSize( aStruct[nI,3] )
			aColumns[nPos]:SetDecimal( aStruct[nI,4] )
			aColumns[nPos]:SetPicture( aStruct[nI,6] )
			aColumns[nPos]:SetType( aStruct[nI,2] )
			aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )

		EndIf
	Next nI

Return( aColumns )

/*/{Protheus.doc} FMarkAll
Inverte a sele��o
@author Felipe Caiado
@since 24/05/2019
@version 1.0
@type Function
/*/
Static Function FMarkAll( oBrowse, lCmpTot, cCmpTot )

	Local cAlias as character
	Local cMark	as character

	cAlias	:=	oBrowse:Alias()
	cMark	:=	oBrowse:Mark()

	lMarkAll	:= .T.

	( cAlias )->( DBGoTop() )

	While ( cAlias )->( !Eof() )

		If RecLock( cAlias, .F. )
			( cAlias )->MARK := Iif( ( cAlias )->MARK == cMark, "  ", cMark )
			( cAlias )->( MsUnlock() )

			If ( cAlias )->MARK == cMark
				nQtdSel ++
			Else
				nQtdSel --
			EndIf

			//Verifica se existe o campo de Total
			If lCmpTot

				If ( cAlias )->MARK == cMark
					nTotSel += ( cAlias )->&(cCmpTot)
				Else
					ntotSel -= ( cAlias )->&(cCmpTot)
				EndIf

			EndIf

		EndIf

		( cAlias )->( DBSkip() )
	EndDo

	( cAlias )->( DBGoTop() )

	//Atualiza o Browse
	oBrowse:Refresh()

	//Atualiza a Quantidade
	oQtdSel:Refresh()

	//Verifica se existe o campo de Total
	If lCmpTot
		//Atualiza o Total
		oTotSel:Refresh()
	EndIf

Return()

/*/{Protheus.doc} FMarkOne
Inverte a sele��o
@author Felipe Caiado
@since 24/05/2019
@version 1.0
@type Function
/*/
Static Function FMarkOne( oBrowse, lCmpTot, cCmpTot )

	Local cAlias as character
	Local cMark	as character

	cAlias	:=	oBrowse:Alias()
	cMark	:=	oBrowse:Mark()

	lMarkAll	:= .T.

	If ( cAlias )->MARK == cMark
		nQtdSel ++
	Else
		nQtdSel --
	EndIf

	//Verifica se existe o campo de Total
	If lCmpTot

		If ( cAlias )->MARK == cMark
			nTotSel += ( cAlias )->&(cCmpTot)
		Else
			ntotSel -= ( cAlias )->&(cCmpTot)
		EndIf

	EndIf

	//Atualiza o Browse
	oBrowse:Refresh()

	//Atualiza a Quantidade
	oQtdSel:Refresh()

	//Verifica se existe o campo de Total
	If lCmpTot
		//Atualiza o Total
		oTotSel:Refresh()
	EndIf

Return()

//-----------------------------------------------------------
/*/{Protheus.doc} CrgMarkB
Carrega o MArkBrowse
@author Felipe Caiado
@since 24/05/2019
@version 1.0

@type Function
/*/
//-----------------------------------------------------------
Static Function CrgMarkB(cAliasBrw, aCampos, aDados)

	Local nX as numeric
	Local ny as numeric

	nX := 0
	ny := 0

	For nX:=1 To Len(aDados)

		Reclock(cAliasBrw,.T.)
			For nY:=1 To Len(aCampos)
				(cAliasBrw)->&(aCampos[nY][1]) := aDados[nX][nY]
			Next nY
		(cAliasBrw)->(MsUnlock())

	Next nX

Return()
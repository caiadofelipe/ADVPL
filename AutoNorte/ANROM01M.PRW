#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} ABROM01N
Ponto de Entrada
@param Não tem
@return Não retorna nada
@author Totvs Nordeste (Anderson)
@version Protheus 10, Protheus 11, V12

/*/
User Function ANROM01M()
	Local aArea     	:= GetArea()
	Local aParam     	:= PARAMIXB
	Local xRet       	:= .T.
	Local oObj       	:= ""
	Local cIdPonto   	:= ""
	Local cIdModel   	:= ""
	Local lIsGrid    	:= .F.
	Local nX		 	:= 0
	Local oModel     	:= FWModelActive()
	Local aChaveD1		:= {}

	If aParam <> NIL
		oObj     := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid  := (Len(aParam ) > 3)
	else
		RestArea(aArea)
		Return xRet
	EndIf

	If cIdPonto == "FORMPOS"

		If cIdModel == "SZCMASTER"
			oObjDet    	:= FwModelActivate()
			oObjSZA 	:= oObjDet:GetModel("SZADETAIL")

			For nX := 1 to oObjSZA:Length()

				oObjSZA:GoLine(nX)

				If !oObjSZA:IsDeleted() //Deletado

					oObjDet    	:= FwModelActivate()
					oObjSZD 	:= oObjDet:GetModel("SZDDETAIL")

					nQtdNF := 0

					For nY := 1 to oObjSZD:Length()
						oObjSZD:GoLine(nY)

						If !oObjSZD:IsDeleted() //Deletado

							nQtdNF ++

						EndIf

					Next nY

				EndIf

				If oObjSZA:GetValue("ZA_QTDNF") <> nQtdNF

					Help( ,, 'HELP',, 'Número de nota fiscais diferente do romaneio', 1, 0)
					Return(.F.)

				EndIf


			Next nX

		EndIf


	ElseIf cIdPonto == "MODELCOMMITTTS"

		If oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4

			If oObj:GetOperation() == 3
				Reclock("SZC",.F.)
				SZC->ZC_STATUS := "1"
				SZC->(MsUnlock())

			EndIf

			DbSelectArea("SZD")
			SZD->(DbSetOrder(1))
			If SZD->(DbSeek(xFilial("SZD")+SZC->ZC_DOC))
				While !SZD->(Eof()) .And. xFilial("SZD")+SZC->ZC_DOC == SZD->(ZD_FILIAL+ZD_ROMANEI)

					Reclock("SZD",.F.)
					SZD->ZD_CODFORN := SZC->ZC_CODFORN
					SZD->ZD_LOJA 	:= SZC->ZC_LOJAFOR
					SZD->(MsUnlock())

					aadd(aChaveD1,{SZD->ZD_NF, SZD->ZD_SERIE, SZD->ZD_CODFORN, SZD->ZD_LOJA, SZD->ZD_ITEM, SZD->ZD_VOLUME, SZD->ZD_VOLUME})

					SZD->(DbSkip())

				EndDo

			EndIf

			For nH:=1 to Len(aChaveD1)
				_cChave := aChaveD1[nH,1]+aChaveD1[nH,2]+aChaveD1[nH,3]+aChaveD1[nH,4]
				_nVolNF := aChaveD1[nH,6]
				_nTotVol := aChaveD1[nH,7]
				DbSelectArea("SF1")
				SF1->(DbSetOrder(1))
				SF1->(DbSeek(xFilial("SF1") + _cChave))
				RecLock("SF1",.F.)
				SF1->F1_STATCON := "0"  // Flag para conferencia fisica
				SF1->(MsUnLock())

				//Posiciona na SZC
				dbSelectArea("SD1")
				SD1->(dbSetOrder(1))
				SD1->(DbSeek(xFilial()+aChaveD1[nH,1]+aChaveD1[nH,2]+aChaveD1[nH,3]+aChaveD1[nH,4]))
				While !Eof() .and. xFilial("SD1")+aChaveD1[nH,1]+aChaveD1[nH,2]+aChaveD1[nH,3]+aChaveD1[nH,4] == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
					F_ConfWMS(SZC->ZC_DOC,_cChave, _nVolNF, _nTotVol)				// Inclusão para conferencia
					dbSelectArea("SD1")
					SD1->(dbSkip())
				EndDo
			Next

		ElseIf oObj:GetOperation() == 5

			Ex_ConfWMS(SZC->ZC_DOC)

		EndIf

	EndIf

	RestArea(aArea)
Return xRet

/*/{Protheus.doc} F_ConfWMS
Gravação
@author felipe.caiado
@since 11/03/2019
@version 1.0
@type function
/*/
Static Function F_ConfWMS(cNroAvs,cChave, _nVolNF, _nTotVol)

	Local lNovo := .F.

	//Verifica se o aviso de recebimento de carga já foi inserido na conferência
	dbSelectArea("DCW")
	DCW->(dbSetOrder(1))

	If !DCW->(dbSeek(xFilial("DCW")+cNroAvs))
		RecLock("DCW",.T.)

		Replace DCW_FILIAL with xFilial("DCW")
		Replace DCW_EMBARQ with cNroAvs
		Replace DCW_SITEMB with "1"
		Replace DCW_DATGER with dDataBase
		Replace DCW_TPCONF with "1"
		Replace DCW_HORGER with Time()
		Replace DCW_XFORNE with SF1->F1_FORNECE
		Replace DCW_XLOJA  with SF1->F1_LOJA
		Replace DCW_XNOME  with Posicione("SA2",1,xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA,"A2_NOME")
		Replace DCW_QTVOLU 	with _nTotVol
		DCW->(MsUnLock())
	Endif

	//Verifica se a nota fiscal já foi inseria na conferência
	dbSelectArea("DCX")
	DCX->(dbSetOrder(2))

	If !DCX->(dbSeek(xFilial("DCX")+ cChave ))
		RecLock("DCX",.T.)
		Replace DCX_FILIAL 	with xFilial("DCY")
		Replace DCX_EMBARQ 	with cNroAvs
		Replace DCX_DOC 	with SD1->D1_DOC
		Replace DCX_SERIE 	with SD1->D1_SERIE
		Replace DCX_FORNEC 	with SD1->D1_FORNECE
		Replace DCX_LOJA 	with SD1->D1_LOJA
		Replace DCX_QTVOLU 	with _nVolNF
		DCX->(MsUnLock())
	Endif

	dbSelectArea("DCY")
	DCY->(dbSetOrder(2))

	lNovo := !DCY->(dbSeek(xFilial("DCY")+cNroAvs+SD1->D1_COD+SD1->D1_LOTECTL+SD1->D1_NUMLOTE))

	RecLock("DCY",lNovo)

	Replace DCY_FILIAL with xFilial("DCY")
	Replace DCY_EMBARQ with cNroAvs
	Replace DCY_PROD   with SD1->D1_COD
	Replace DCY_LOTE   with SD1->D1_LOTECTL
	Replace DCY_SUBLOT with SD1->D1_NUMLOTE
	Replace DCY_QTORIG with IIF(lNovo,SD1->D1_QUANT,DCY->DCY_QTORIG + SD1->D1_QUANT)
	Replace DCY_LOCAL  with SD1->D1_LOCAL
	Replace DCY_PRDORI with SD1->D1_COD

	DCY->(MsUnLock())

	dbSelectArea("D0K")
	dbSetOrder(1)
	If !dbSeek(xFilial()+cNroAvs+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD+SD1->D1_ITEM)

		// Grava o relacionamento dos itens do documento com a conferência
		RecLock('D0K',.T.)
		D0K->D0K_FILIAL := xFilial('D0K')
		D0K->D0K_EMBARQ := cNroAvs
		D0K->D0K_DOC    := SD1->D1_DOC
		D0K->D0K_SERIE  := SD1->D1_SERIE
		D0K->D0K_FORNEC := SD1->D1_FORNECE
		D0K->D0K_LOJA   := SD1->D1_LOJA
		D0K->D0K_ITEM   := SD1->D1_ITEM
		D0K->D0K_LOCAL  := SD1->D1_LOCAL
		D0K->D0K_PROD   := SD1->D1_COD
		D0K->D0K_LOTE   := SD1->D1_LOTECTL
		D0K->D0K_SUBLOT := SD1->D1_NUMLOTE
		D0K->D0K_QUANT  := SD1->D1_QUANT
		D0K->(MsUnlock())
	Endif
Return

/*/{Protheus.doc} Ex_ConfWMS
Exclusão
@author felipe.caiado
@since 11/03/2019
@version 1.0
@type function
/*/
Static Function Ex_ConfWMS(cNroAvs)

	Local _aArea := GetArea()

	dbSelectArea("DCW")
	DCW->(dbSetOrder(1))
	If DCW->(dbSeek(xFilial("DCW")+cNroAvs))
		Reclock("DCW",.F.,.T.)
		dbDelete()
		MsUnlock()
	Endif

	//Verifica se a nota fiscal já foi inseria na conferência
	dbSelectArea("DCX")
	DCX->(dbSetOrder(1))

	DCX->(dbSeek(xFilial("DCX")+ cNroAvs ))
	While !Eof() .and. xFilial("DCX")+ cNroAvs == DCX->(DCX_FILIAL + DCX_EMBARQ)
		dbSelectArea("SF1")
		dbSetOrder(1)
		If dbSeek(xFilial()+DCX->DCX_DOC+DCX->DCX_SERIE+DCX->DCX_FORNEC+DCX->DCX_LOJA)
			RecLock("SF1",.F.)
			Replace F1_STATCON with " "
			MsUnLock()
		Endif
		dbSelectArea("DCX")
		Reclock("DCX",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	End
	dbSelectArea("DCY")
	DCY->(dbSetOrder(1))
	DCY->(dbSeek(xFilial("DCY")+cNroAvs))
	While !Eof() .and. xFilial("DCY")+ cNroAvs == DCY->(DCY_FILIAL + DCY_EMBARQ)
		dbSelectArea("DCY")
		Reclock("DCY",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	End
	dbSelectArea("D0K")
	dbSetOrder(1)
	dbSeek(xFilial()+cNroAvs)
	While !Eof() .and. xFilial("D0K")+ cNroAvs == D0K->(D0K_FILIAL + D0K_EMBARQ)
		dbSelectArea("D0K")
		Reclock("D0K",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	End
	RestArea(_aArea)
Return

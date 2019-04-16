#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE SM0_FILIAL	02

/*/{Protheus.doc} CADZZIM
Pontos de Entrada no cadastro de centro de custo
@author felipecaiado
@since 03/03/2016
@version undefined

@type function
/*/
User Function CADZZIM()

	Local aParam     	:= PARAMIXB
	Local xRet       	:= .T.
	Local oObj       	:= ""
	Local cIdPonto   	:= ""
	Local cIdModel   	:= ""
	Local cClasse    	:= ""

	Local nLinha     	:= 0
	Local nQtdLinhas 	:= 0
	Local aLetra		:= {}
	Local nX			:= 0
	Local nY			:= 0
	Local aAreaSM0		:= SM0->(GetArea())
	Local aAreaZZI		:= ZZI->(GetArea())
	Local cLetra		:= ""
	Local lAtual		:= .F.
	Local aReplica		:= FWLoadSM0(.T.)

	If aParam <> NIL

		oObj		:= aParam[1]
		cIdPonto 	:= aParam[2]
		cIdModel 	:= IIf( oObj<> NIL, oObj:GetId(), aParam[3] )
		cClasse   	:= IIf( oObj<> NIL, oObj:ClassName(), '' )

		If cClasse == 'FWFORMGRID'
			nQtdLinhas := oObj:Length()
			nLinha     := oObj:nLine
		EndIf

		If cIdPonto ==  'MODELCOMMITNTTS'

			If oObj:GetOperation() ==  MODEL_OPERATION_INSERT

				If ApMsgYesNo("Grava a letra em todas as empresas?")

					Begin Transaction

					aStruct := ZZI->(DbStruct())

					cLetra := ZZI->ZZI_LETRA

					For nX:=1 To Len(aStruct)

						aAdd(aLetra, { aStruct[nX][1], ZZI->&( aStruct[nX][1] ) } )

					Next nX

					nX := 0

					For nX:=1 To Len(aReplica)

						If Substr(aReplica[nX][SM0_FILIAL],1,2) <> "02"
							Loop
						EndIF

						If Alltrim(aReplica[nX][SM0_FILIAL]) <> Alltrim(xFilial("ZZI"))

							lAtual := .F.

							DbSelectArea("ZZI")
							ZZI->(DbSetOrder(1))
							If ZZI->(DbSeek(aReplica[nX][SM0_FILIAL]+cLetra))
								Reclock("ZZI",.F.)
								lAtual := .T.
							Else
								Reclock("ZZI",.T.)
								lAtual := .F.
							EndIf

							For nY:=1 To Len(aLetra)

								If Alltrim(aLetra[nY][1]) == "ZZI_FILIAL"
									If !lAtual
										ZZI->ZZI_FILIAL := aReplica[nX][SM0_FILIAL]
									EndIf
									Loop
								EndIf

								If Alltrim(aLetra[nY][1]) == "ZZI_LETRA"
									If !lAtual
										ZZI->ZZI_LETRA := cLetra
									EndIf
									Loop
								EndIf

								ZZI->&( aLetra[nY][1] ) := aLetra[nY][2]

							Next nY

							ZZI->(MsUnlock())

						EndIf

					Next nX

					End Transaction

				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(aAreaSM0)
	RestArea(aAreaZZI)

Return xRet
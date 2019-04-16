#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE SM0_FILIAL	02
#DEFINE SM0_CNPJ	18

//-------------------------------------------------------------
/*/{Protheus.doc} ANFAT01A
Geração de nota fiscal de entrada para transferência
@author felipe.caiado
@since 13/03/2019
@version 1.0

@param cEmpCo, characters, Empresa
@param cFiLCon, characters, Filial
@type function
/*/
//-------------------------------------------------------------
User Function ANFAT01A(cEmpCon, cFiLCon)

	Local nQtde 	as numeric
	Local lRet		as logical
	Local cAliasSF2	as character


	//Prepara a conexão
	RPCSetType(3)  // Nao comer licensa
	Prepare Environment Empresa cEmpCon Filial cFiLCon Tables 'SF2','SA1','SD2'

	nQtde 		:= 0
	cAliasSF2 	:= GetNextAlias()

	//Enquando não acabar o processo
	While !KillApp()

		nQtde ++

		//Tratamento para liberação de memória do Server
		If nQtde == 10
			FwLogMsg("INFO", /*cTransactionId*/, "JOB", FunName(), "", "01", "Parada do Job para liberacao de memoria", 0, 0, {})
			Break
		EndIf

		// Verifica se existem registros a serem processados
		lRet := AN001(cAliasSF2)

		If lRet

			FwLogMsg("INFO", /*cTransactionId*/, "JOB", FunName(), "", "01", "Inicio do processamento das notas", 0, 0, {})

			While !(cAliasSF2)->(Eof())

				// Processamento da rotina para criação da nota fiscal
				AN002((cAliasSF2)->F2_FILIAL,(cAliasSF2)->F2_DOC,(cAliasSF2)->F2_SERIE,(cAliasSF2)->F2_CLIENTE,(cAliasSF2)->F2_LOJA)

				(cAliasSF2)->(DbSkip())

			EndDo

		Else

			FwLogMsg("INFO", /*cTransactionId*/, "JOB", FunName(), "", "01", "Nao ha dados para processar", 0, 0, {})

		EndIf

		(cAliasSF2)->(DbCloseArea())

		//Pausa para o proximo processamento
		Sleep(6000)

	EndDo

	Reset Environment

Return

//-------------------------------------------------------------
/*/{Protheus.doc} AN001
Verificação se existem registro a serem processados
@author felipe.caiado
@since 13/03/2019
@version 1.0
@param cAliasSF2, characters, Alias para a query
@type function
/*/
//-------------------------------------------------------------
Static Function AN001(cAliasSF2)

	Local lRet		as logical

	lRet := .T.

	//Query de Pesquisa
	BeginSQL alias cAliasSF2
		SELECT
			F2_FILIAL,
			F2_DOC,
			F2_SERIE,
			F2_CLIENTE,
			F2_LOJA
		FROM
			%table:SF2% SF2, %table:SD2% SD2, %table:SF4% SF4
		WHERE
			F2_FILIAL = %xFilial:SF2% AND
			F2_FILIAL BETWEEN '      ' AND 'ZZZZZZ' AND
			F2_XINTEGR = ' ' AND
			F2_EMISSAO >= '20190313' AND
			F2_FILIAL = D2_FILIAL AND
			F2_DOC = D2_DOC AND
			F2_SERIE = D2_SERIE AND
			F2_CLIENTE = D2_CLIENTE AND
			F2_LOJA = D2_LOJA AND
			F4_FILIAL = %xFilial:SF4% AND
			D2_TES = F4_CODIGO AND
			F4_ESTOQUE = 'S' AND
			F4_TRANFIL = '1' AND
			SF2.%notDel% AND
			SD2.%notDel% AND
			SF4.%notDel%
		GROUP BY
			F2_FILIAL,
			F2_DOC,
			F2_SERIE,
			F2_CLIENTE,
			F2_LOJA
	EndSql

	//Verifica se o arquivo estpa vazio
	If (cAliasSF2)->( Eof() )

		lRet := .F.

	EndIf

Return(lRet)

//-------------------------------------------------------------
/*/{Protheus.doc} AN002
Criação da nota fiscal
@author felipe.caiado
@since 13/03/2019
@version 1.0
@param cFilNF, characters, Filial da nota
@param cNota, characters, Numero da nota
@param cSerie, characters, Serie da nota
@param cCliente, characters, Cliente da nota
@param cLoja, characters, Loja do cliente
@type function
/*/
//-------------------------------------------------------------
Static Function AN002(cFilNF, cNota, cSerie, cCliente, cLoja)

	Local cCNPJOrig		as character
	Local aSM0			as array
	Local nX			as numeric
	Local oServer 		as object
	Local cRpcServer	as character
	Local nRPCPort 		as numeric
	Local cRPCEnv 		as character
	Local lRet			as logical
	Local cFilDest		as character
	Local cItem			as character
	Local aCab			as array
	Local aLinha		as array
	Local aItens		as array

	aCab 			:= {}
	aLinha			:= {}
	aItens			:= {}
	cItem			:= Replicate("0",TamSX3("D1_ITEM")[1])
	cRpcServer		:= "localhost"
	nRPCPort 		:= 1234
	cRPCEnv			:= Alltrim(Upper(GetEnvServer()))

	//Dados do SM0
	aSM0 := FWLoadSM0(.T.)

	//Posiciona na Nota Fiscal
	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA
	If SF2->(DbSeek(cFilNF+cNota+cSerie+cCliente+cLoja))

		DbSelectArea("SD2")
		SD2->(DbSetOrder(3))//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA
		If SD2->(DbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

			While !SD2->(Eof()) .And. SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA ==;
			SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA

				//Itens da nota fiscal de entrada
				aLinha  := {}
				cItem := Soma1(cItem)
				aAdd(aLinha,{"D1_ITEM"	,cItem														,Nil})
				aAdd(aLinha,{"D1_COD"	,SD2->D2_COD												,Nil})
				aAdd(aLinha,{"D1_QUANT"	,SD2->D2_QUANT												,Nil})
				aAdd(aLinha,{"D1_VUNIT"	,Round(SD2->D2_PRCVEN,TamSX3("D2_PRCVEN")[2])				,Nil})
				aAdd(aLinha,{"D1_TOTAL"	,SD2->D2_TOTAL												,Nil})
				aAdd(aLinha,{"D1_LOCAL"	,Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_LOCPAD")	,Nil})
				aAdd(aLinha,{"D1_OPER"	,"01"														,Nil})

				aAdd(aItens,aLinha)

				SD2->(DbSkip())

			EndDo

		EndIf

		FwLogMsg("INFO", /*cTransactionId*/, "JOB", FunName(), "", "01", "Procesando Nota Fiscal " + cFilNF + "|" + cNota + "|" + cSerie, 0, 0, {})

		//Posiciona no Cliente
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
		SA1->(DbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA)))

		//Pesquisa o CNPJ da filial de origem
		For nX:=1 To Len(aSM0)

			//Verifica se a filial é igual a da nota
			If Alltrim(aSM0[nX][SM0_FILIAL]) == Alltrim(cFilNF)

				cCNPJOrig := Alltrim(aSM0[nX][SM0_CNPJ])

			EndIf

			//Verifica o CNPJ do destino
			If Alltrim(aSM0[nX][SM0_CNPJ]) == Alltrim(SA1->A1_CGC)

				cFilDest := Alltrim(aSM0[nX][SM0_FILIAL])

			EndIf

		Next nX

		//Verifica se o CNPJ de Origem está vazio
		If !Empty(cCNPJOrig)

			//Posiciona no fornecedor da loja de origem da nota
			DbSelectArea("SA2")
			SA2->(DbSetOrder(3))//A2_FILIAL+A2_COD+A2_LOJA
			If SA2->(DbSeek(xFilial("SA2")+cCNPJOrig))

				// Cabecalho da nota fiscal de entrada
				aAdd(aCab,{"F1_TIPO"   	,"N"				})
				aAdd(aCab,{"F1_FORMUL" 	,"N"				})
				aAdd(aCab,{"F1_DOC"    	,SF2->F2_DOC		})
				aAdd(aCab,{"F1_SERIE"  	,SF2->F2_SERIE		})
				aAdd(aCab,{"F1_EMISSAO"	,SF2->F2_EMISSAO	})
				aAdd(aCab,{"F1_FORNECE"	,SA2->A2_COD		})
				aAdd(aCab,{"F1_LOJA"   	,SA2->A2_LOJA		})
				aAdd(aCab,{"F1_ESPECIE"	,"SPED"				})
				aAdd(aCab,{"F1_EST"		,SA1->A1_EST		})

				// Criando objeto do tipo tRpc
				oServer := TRPC():New( cRPCEnv )

				// Conectando ao servidor
				If oServer:Connect( cRpcServer, nRPCPort )

					// Executando Funcao
					lRet := oServer:CallProc("U_ANFAT01B", aCab, aItens, cEmpAnt, cFilDest )

					// Desconectando do servidor
					oServer:Disconnect()

					If lRet

						//Marca como integrada a nota de saída
						Reclock('SF2',.F.)
						SF2->F2_XINTEGR := 'S'
						SF2->(MsUnLock())

					EndIf

				Else

					FwLogMsg("INFO", /*cTransactionId*/, "JOB", FunName(), "", "01", "Sem conexao com o SERVER para criar a pre-nota", 0, 0, {})

				EndIf

			EndIf
		Else

			FwLogMsg("INFO", /*cTransactionId*/, "JOB", FunName(), "", "01", "Nao achou a filial no SM0", 0, 0, {})

		EndIf

	Else

		FwLogMsg("INFO", /*cTransactionId*/, "JOB", FunName(), "", "01", "Nota Fiscal não localizada: " + cFilNF + "|" + cNota + "|" + cSerie, 0, 0, {})

	EndIf

Return()

//-------------------------------------------------------------
/*/{Protheus.doc} ANFAT01B
Criação da Pre nota
@author felipe.caiado
@since 13/03/2019
@version 1.0
@param aCab, array, Cabecalho da nota
@param aDet, array, Itens da Nota
@param cEmpDest, characters, Empresa
@param cFilDes, characters, Filial
@type function
/*/
//-------------------------------------------------------------
User Function ANFAT01B(aCab, aItens, cEmpDest, cFilDes)

	Local lRet		as logical

	lRet := .T.

	//Conecta na filial de destino
	RpcSetEnv(cEmpDest, cFilDes)

	//Insere as notas fiscais
	lMsErroAuto := .f.
	MSExecAuto({|x,y,z| MATA140(x,y,z)},aCab,aItens,3)

	If lMsErroAuto
		lRet := .F.
		Conout(MostraErro())
	EndIf

	//Desconecta da filial
	RpcClearEnv()

Return(lRet)
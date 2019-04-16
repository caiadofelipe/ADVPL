#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWEditPanel.CH'

#DEFINE SM0_FILIAL	02

//-------------------------------------------------------------------
/*/{Protheus.doc} ANCOM02
Manutenção do Markup
@author felipe.caiado
@since 13/03/2019
/*/
//-------------------------------------------------------------------
User Function ANCOM02A()

	Local aButtons 		:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}

	SetKEY( VK_F4, {|| 	AN007()} )
	SetKEY( VK_F5, {|| 	AN008()} )
	SetKEY( VK_F7, {|| 	FwMsgRun(Nil,{||AN005(2) },Nil,"Aguarde, Atualizando Markup...")} )
	SetKEY( VK_F8, {|| 	FwMsgRun(Nil,{||AN006() },Nil,"Aguarde, Importando Arquivo...")} )

	FWExecView("Manutenção de MARKUP","ANCOM02",MODEL_OPERATION_UPDATE,,{|| .T.},,,aButtons	)

	SetKEY( VK_F4, NIL )
	SetKEY( VK_F5, NIL )
	SetKEY( VK_F7, NIL )
	SetKEY( VK_F8, NIL )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Manutenção do Markup - Modelo de Dados
@author felipe.caiado
@since 13/03/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZZZ 	:= FWFormStruct( 1, 'ZZZ')
	Local oStruZZH 	:= FWFormStruct( 1, 'ZZH', {|cCampo| Alltrim(cCampo) $ 'ZZH_MARCA/ZZH_GRUPO/ZZH_NREDUZ'},/*lViewUsado*/ )
	Local oItemZZH 	:= FWFormStruct( 1, 'ZZH', {|cCampo| Alltrim(cCampo) $ 'ZZH_FILAN/ZZH_MKMNF/ZZH_MKNMNF/ZZH_INDICE'},/*lViewUsado*/ )
	Local oModel
	Local bLoadF	:= {|oFieldModel, lCopy| AN001(oFieldModel, lCopy)}
	Local bLoadG1 	:= {|oGridModel, lCopy| AN002(oGridModel, lCopy)}
	Local bLoadG2 	:= {|oGridModel, lCopy| AN003(oGridModel, lCopy)}

	//Estrutura do Filtro
	oStruZZZ:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Marca') , ; 		// [02] C ToolTip do campo
	'XX_USUARIO' , ;            // [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	20 , ;  					// [05] N Tamanho do campo
	0 , ;  						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruZZZ:SetProperty("*",MODEL_FIELD_WHEN,{|| .F.})
	oStruZZH:SetProperty("*",MODEL_FIELD_WHEN,{|| .F.})
	oItemZZH:SetProperty("ZZH_FILAN",MODEL_FIELD_WHEN,{|| .F.})

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('ANCOM02M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'ZZZMASTER', /*cOwner*/, oStruZZZ, /*bPreValidacao*/, /*bPosValidacao*/, bLoadF)

	// Adiciona ao modelo uma estrutura de Grid
	oModel:AddGrid( 'ZZHDETAIL1', 'ZZZMASTER', oStruZZH, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, bLoadG1 )
	oModel:AddGrid( 'ZZHDETAIL2', 'ZZZMASTER', oItemZZH, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, bLoadG2 )

	//Chave Primaria
	oModel:SetPrimaryKey( { , })

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Manutenção do Markup' )

	oModel:GetModel( 'ZZZMASTER' ):SetOnlyView( .T. )
	oModel:GetModel( 'ZZZMASTER' ):SetOnlyQuery( .T. )

	oModel:GetModel( 'ZZHDETAIL1' ):SetOnlyView( .T. )
	oModel:GetModel( 'ZZHDETAIL1' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'ZZHDETAIL1' ):SetOptional( .T. )

	oModel:GetModel( 'ZZHDETAIL2' ):SetOnlyView( .T. )
	oModel:GetModel( 'ZZHDETAIL2' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'ZZHDETAIL2' ):SetOptional( .T. )

	oModel:GetModel( 'ZZHDETAIL1' ):SetMaxLine(99999)

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'ZZZMASTER' ):SetDescription( 'Manutenção do Markup' )
	oModel:GetModel( 'ZZHDETAIL1' ):SetDescription( 'Manutenção do Markup' )
	oModel:GetModel( 'ZZHDETAIL2' ):SetDescription( 'Manutenção do Markup' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Manutenção do Markup - Interface com usuário
@author felipe.caiado
@since 13/03/2019
@version undefined

@type function
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   	:= FWLoadModel( 'ANCOM02' )
	// Cria a estrutura a ser usada na View
	Local oStruZZZ 	:= FWFormStruct( 2, 'ZZZ')
	Local oStruZZH 	:= FWFormStruct( 2, 'ZZH', {|cCampo| Alltrim(cCampo) $ 'ZZH_MARCA/ZZH_GRUPO/ZZH_NREDUZ'} )
	Local oItemZZH 	:= FWFormStruct( 2, 'ZZH', {|cCampo| Alltrim(cCampo) $ 'ZZH_FILAN/ZZH_MKMNF/ZZH_MKNMNF/ZZH_INDICE'} )
	Local oView
	Local cOrdem 	:= "00"

	cOrdem := Soma1( cOrdem )
	oStruZZZ:AddField( ;            	// Ord. Tipo Desc.
	'XX_USUARIO'					, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Usuário'    )			, ; // [03]  C   Titulo do campo
	AllTrim( 'Usuário' )			, ; // [04]  C   Descricao do campo
	{ 'Usuário' } 					, ; // [05]  A   Array com Help
	'C'                           	, ; // [06]  C   Tipo do campo
	'@!'                			, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	oStruZZH:SetProperty("ZZH_MARCA", MVC_VIEW_TITULO , "Fornecedor")
	oStruZZH:SetProperty("ZZH_GRUPO", MVC_VIEW_TITULO , "Linha")
	oStruZZH:SetProperty("ZZH_NREDUZ", MVC_VIEW_TITULO , "Nome Fornec / Linha")

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZZZ', oStruZZZ, 'ZZZMASTER' )

	//Adiciona no nosso View um controle do tipo Grid(antiga GetDados)
	oView:AddGrid( 'VIEW_ZZH1', oStruZZH, 'ZZHDETAIL1' )
	oView:AddGrid( 'VIEW_ZZH2', oItemZZH, 'ZZHDETAIL2' )

	oView:SetViewProperty('VIEW_ZZH1', "CHANGELINE", {{ |oView, cViewID| AN004() }} ) //Mudança de linha
	oView:SetViewProperty("VIEW_ZZH1", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| AN005(1)}})//Duplo Clique
	oView:SetViewProperty("VIEW_ZZH1", "GRIDSEEK", {.T.}) //Habilita a pesquisa

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR' , 0 )
	oView:CreateHorizontalBox( 'INFERIOR' , 100 )
	oView:CreateVerticalBox( 'INFESQ' , 50,'INFERIOR'  )
	oView:CreateVerticalBox( 'INFDIR' ,50,'INFERIOR'  )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZZZ', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_ZZH1', 'INFESQ' )
	oView:SetOwnerView( 'VIEW_ZZH2', 'INFDIR' )

	oView:SetOnlyView( "VIEW_ZZZ")
	//	oView:SetOnlyView( "VIEW_ZZH1")
	//	oView:SetOnlyView( "VIEW_ZZH2")

	//Indica se a janela deve ser fechada ao final da operação. Se ele retornar .T. (verdadeiro) fecha a janela
	oView:bCloseOnOK := {|| .T.}

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} AN001
Carga do Cabeçalho
@author felipe.caiado
@since 26/03/2019
@version 1.0
@param oFieldModel, object, Modelo
@param lCopy, logical, Copia?
@type function
/*/
//-------------------------------------------------------------------
Static Function AN001(oFieldModel, lCopy)

	Local aLoad as Array

	aLoad := {}

	//Carrega os dados
	aAdd(aLoad, {""}) //dados
	aAdd(aLoad, 1) //recno

Return(aLoad)

//-------------------------------------------------------------------
/*/{Protheus.doc} AN002
Carga na grid de Fornecedor
@author felipe.caiado
@since 26/03/2019
@version 1.0
@param oGridModel, object, Modelo
@param lCopy, logical, Copia?
@type function
/*/
//-------------------------------------------------------------------
Static Function AN002(oGridModel, lCopy)

	Local aLoad 	as Array
	Local cAliasZZH	as character
	Local cNome		as character

	cAliasZZH 	:= GetNextAlias()
	cNome 		:= ""

	BeginSQL alias cAliasZZH
		SELECT
		ZZH_MARCA,
		ZZH_GRUPO
		FROM
		%table:ZZH% ZZH
		WHERE
		ZZH_FILIAL = %exp:xFilial("ZZH")%
		AND ZZH.%notDel%
		GROUP BY
		ZZH_MARCA,
		ZZH_GRUPO
		ORDER BY
		ZZH_MARCA,
		ZZH_GRUPO
	EndSql

	aLoad := {}

	While (cAliasZZH)->( !Eof() )

		//Nome do Fornecedor ou Linha
		If Empty((cAliasZZH)->ZZH_GRUPO)
			DbSelectArea("ZZM")
			ZZM->(DbSetOrder(2))//ZZM_FILIAL+ZZM_CODMAR
			If ZZM->(DbSeek(xFilial("ZZM")+(cAliasZZH)->ZZH_MARCA))

				DbSelectArea("SA2")
				SA2->(DbSetOrder(1))//A2_FILIAL+A2_FORNECE+A2_LOJA
				If SA2->(DbSeek(xFilial("SA2")+ZZM->ZZM_FORNEC+ZZM->ZZM_LOJA))
					cNome := SA2->A2_NOME
				Else
					cNome := ""
				EndIf

			Else

				cNome := ""

			EndIf
		Else

			DbSelectArea("ZZ8")
			ZZ8->(DbSetOrder(1))//ZZ8_FILIAL+ZZ8_LINHA
			If ZZ8->(DbSeek(xFilial("ZZ8")+(cAliasZZH)->ZZH_GRUPO))
				cNome := ZZ8->ZZ8_DESCRI
			Else
				cNome := ""
			EndIf

		EndIf

		aAdd(aLoad,{0,{(cAliasZZH)->ZZH_MARCA, (cAliasZZH)->ZZH_GRUPO, cNome}})

		(cAliasZZH)->( DbSkip() )

	EndDo

	(cAliasZZH)->( DbCloseArea() )

Return(aLoad)

//-------------------------------------------------------------------
/*/{Protheus.doc} AN003
Carga na grid de Valores
@author felipe.caiado
@since 26/03/2019
@version 1.0
@param oGridModel, object, Modelo
@param lCopy, logical, Copia?
@type function
/*/
//-------------------------------------------------------------------
Static Function AN003(oGridModel, lCopy)

	Local aLoad 	as Array
	Local cAliasZZH	as character

	cAliasZZH 	:= GetNextAlias()

	BeginSQL alias cAliasZZH
		SELECT
		ZZH_FILAN,
		ZZH_MKMNF,
		ZZH_MKNMNF,
		ZZH_INDICE
		FROM
		%table:ZZH% ZZH
		WHERE
		ZZH_FILIAL = %exp:xFilial("ZZH")%
		AND ZZH_MARCA = '3RHO '
		AND ZZH_GRUPO = '     '
		AND ZZH.%notDel%
		ORDER BY
		ZZH_FILAN
	EndSql

	aLoad := {}

	While (cAliasZZH)->( !Eof() )

		aAdd(aLoad,{0,{(cAliasZZH)->ZZH_FILAN, (cAliasZZH)->ZZH_MKMNF, (cAliasZZH)->ZZH_MKNMNF, (cAliasZZH)->ZZH_INDICE}})

		(cAliasZZH)->( DbSkip() )

	EndDo

	(cAliasZZH)->( DbCloseArea() )

Return(aLoad)

//-------------------------------------------------------------------
/*/{Protheus.doc} AN004
Atualiza registro de valores
@author felipe.caiado
@since 13/03/2019
@version undefined
@type function
/*/
//-------------------------------------------------------------------
Static Function AN004()

	Local oModel     	:= FWModelActive()
	Local oView			:= FwViewActive()
	Local oZZH1Mod  	:= oModel:GetModel( 'ZZHDETAIL1' )
	Local oZZH2Mod  	:= oModel:GetModel( 'ZZHDETAIL2' )
	Local cAliasZZH		:= GetNextAlias()
	Local cMarca		:= ""
	Local cLinha		:= ""
	Local nLinhaZZH  	:= 1

	cMarca := oZZH1Mod:GetValue("ZZH_MARCA")
	cLinha := oZZH1Mod:GetValue("ZZH_GRUPO")

	//Limpa o Grid
	oZZH2Mod:ClearData(.F.,.T.)

	DbSelectArea("ZZH")
	ZZH->(DbSetOrder(1))//ZZH_FILIAL+ZZH_MARCA+ZZH_GRUPO+ZZH_FILAN
	If ZZH->(DbSeek(xFilial("ZZH")+cMarca+cLinha))

		//Alimenta o Grid de Valores
		While !ZZH->(Eof()) .And. xFilial("ZZH")+cMarca+cLinha == ZZH_FILIAL+ZZH_MARCA+ZZH_GRUPO

			oZZH2Mod:SetNoInsertLine(.F.)

			If nLinhaZZH > 1
				If oZZH2Mod:AddLine() <> nLinhaZZH
					Help( ,, 'HELP',, 'Nao incluiu linha SB1' + CRLF + oModel:getErrorMessage()[6], 1, 0)
					Loop
				EndIf
			EndIf

			oZZH2Mod:SetNoInsertLine(.T.)

			lUpdCNF := oZZH2Mod:CanUpdateLine()

			If !lUpdCNF
				oZZH2Mod:SetNoUpdateLine(.F.)
			EndIf

			oZZH2Mod:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})

			oZZH2Mod:SetValue( 'ZZH_FILAN',ZZH->ZZH_FILAN )
			oZZH2Mod:SetValue( 'ZZH_MKMNF',ZZH->ZZH_MKMNF )
			oZZH2Mod:SetValue( 'ZZH_MKNMNF',ZZH->ZZH_MKNMNF )
			oZZH2Mod:SetValue( 'ZZH_INDICE',ZZH->ZZH_INDICE )

			oZZH2Mod:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.F.})

			oZZH2Mod:SetNoUpdateLine(!lUpdCNF)

			nLinhaZZH++

			ZZH->(DbSkip())

		Enddo

	EndIf

	oZZH2Mod:GoLine(1)

	oView:Refresh('VIEW_ZZH2')

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AN005
Alterar valores
@author felipe.caiado
@since 13/03/2019
@version undefined
@type function
/*/
//-------------------------------------------------------------------
Static Function AN005(nTipo)

	Local oModel     	:= FWModelActive()
	Local oView			:= FwViewActive()
	Local oZZH1Mod  	:= oModel:GetModel( 'ZZHDETAIL1' )
	Local cMarca		:= ""
	Local cLinha		:= ""

	cMarca := oZZH1Mod:GetValue("ZZH_MARCA")
	cLinha := oZZH1Mod:GetValue("ZZH_GRUPO")

	aRet 	:= {}
	aPerg	:= {}

	aAdd( aPerg ,{1,Alltrim("Marca"),Iif(nTipo==1,oZZH1Mod:GetValue("ZZH_MARCA"),Space(05)),"@!",".T.","",Iif(nTipo==1,".F.",".T."),30,.T.})
	aAdd( aPerg ,{1,Alltrim("Linha"),Iif(nTipo==1,oZZH1Mod:GetValue("ZZH_GRUPO"),Space(05)),"@!",".T.","",Iif(nTipo==1,".F.",".T."),30,.F.})
	aAdd( aPerg ,{1,Alltrim("Filial"),Space(06),"@!",".T.","SM0","",30,.T.})
	aAdd( aPerg ,{1,Alltrim("Markup Monofásico"),0.00,"@E 999.99",".T.","","",30,.F.})
	aAdd( aPerg ,{1,Alltrim("Markup Não Monofásico"),0.00,"@E 999.99",".T.","","",30,.F.})
	aAdd( aPerg ,{1,Alltrim("Fator"),0.00,"@E 999.9999",".T.","","",30,.F.})

	//Mostra tela de Parâmetros
	If !ParamBox(aPerg ,"Atualização de Markup",@aRet)
		Return()
	EndIf

	//Verifica se existe parâmetro vazio
	If Empty(MV_PAR01) .Or. Empty(MV_PAR03)
		ApMsgInfo("Favor preencher todos os parâmetros")
		Return()
	EndIf

	If ApMsgYesNo("Confirma atualização do Markup?")

		If !Empty(MV_PAR02)
			DbSelectArea("ZZH")
			ZZH->(DbSetOrder(1))//ZZH_FILIAL+ZZH_MARCA+ZZH_GRUPO+ZZH_FILAN
			If ZZH->(DbSeek(xFilial("ZZH")+MV_PAR01+MV_PAR02+MV_PAR03))
				Reclock("ZZH",.F.)
				If MV_PAR04 > 0
					ZZH->ZZH_MKMNF	:= MV_PAR04
				EndIf
				If MV_PAR05 > 0
					ZZH->ZZH_MKNMNF	:= MV_PAR05
				EndIf
				If MV_PAR06 > 0
					ZZH->ZZH_INDICE	:= MV_PAR06
				EndIf
				ZZH->(MsUnlock())
			EndIf
		Else
			DbSelectArea("ZZH")
			ZZH->(DbSetOrder(1))//ZZH_FILIAL+ZZH_MARCA+ZZH_GRUPO+ZZH_FILAN
			If ZZH->(DbSeek(xFilial("ZZH")+MV_PAR01))
				While !ZZH->(Eof()) .And. xFilial("ZZH")+MV_PAR01 == ZZH_FILIAL+ZZH_MARCA

					If ZZH->ZZH_FILAN == MV_PAR03

						Reclock("ZZH",.F.)
						If MV_PAR04 > 0
							ZZH->ZZH_MKMNF	:= MV_PAR04
						EndIf
						If MV_PAR05 > 0
							ZZH->ZZH_MKNMNF	:= MV_PAR05
						EndIf
						If MV_PAR06 > 0
							ZZH->ZZH_INDICE	:= MV_PAR06
						EndIf
						ZZH->(MsUnlock())

					EndIf

					ZZH->(DbSkip())

				EndDo
			EndIf
		EndIf

	EndIf

	//Atualiza Grid
	AN004()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AN006
Importar Arquivo CSV
@author felipe.caiado
@since 13/03/2019
@version undefined
@type function
/*/
//-------------------------------------------------------------------
Static Function AN006()

	Local cArq			:= ""

	//Busca o arquivo a ser importado
	cArq := AllTrim( cGetFile( 'Arquivo csv| *.csv |Arquivo texto | *.txt', 'Selecione o arquivo', 0, "", .T.,  GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE  ) )

	If Empty(cArq)
		ApMsgInfo("Favor escolher o arquivo")
		Return()
	EndIf

	If !ApMsgYesNo("Deseja importar o arquivo selecionado?")
		Return()
	EndIf

	//Abre o arquivo para uso
	FT_FUSE(cArq)

	//Posiciona no inicio do arquivo
	FT_FGOTOP()

	While ( !FT_FEOF() )

		// Guarda o conteudo da Linha processada
		cLin := Alltrim( FT_FREADLN() )

		aSepLin := Separa(cLin, ";")

		aSepLin[4] := StrTran(aSepLin[4],",",".")
		aSepLin[5] := StrTran(aSepLin[5],",",".")
		aSepLin[6] := StrTran(aSepLin[6],",",".")

		If !Empty(aSepLin[2])
			DbSelectArea("ZZH")
			ZZH->(DbSetOrder(1))//ZZH_FILIAL+ZZH_MARCA+ZZH_GRUPO+ZZH_FILAN
			If ZZH->(DbSeek(xFilial("ZZH")+PadR(aSepLin[1],5)+PadR(aSepLin[2],5)+aSepLin[3]))
				Reclock("ZZH",.F.)
				If Val(aSepLin[4]) > 0
					ZZH->ZZH_MKMNF	:= Val(aSepLin[4])
				EndIf
				If Val(aSepLin[5]) > 0
					ZZH->ZZH_MKNMNF	:= Val(aSepLin[5])
				EndIf
				If Val(aSepLin[6]) > 0
					ZZH->ZZH_INDICE	:= Val(aSepLin[6])
				EndIf
				ZZH->(MsUnlock())
			EndIf
		Else
			DbSelectArea("ZZH")
			ZZH->(DbSetOrder(1))//ZZH_FILIAL+ZZH_MARCA+ZZH_GRUPO+ZZH_FILAN
			If ZZH->(DbSeek(xFilial("ZZH")+PadR(aSepLin[1],5)))
				While !ZZH->(Eof()) .And. xFilial("ZZH")+PadR(aSepLin[1],5) == ZZH_FILIAL+ZZH_MARCA

					If ZZH->ZZH_FILAN == aSepLin[3]

						Reclock("ZZH",.F.)
						If Val(aSepLin[4]) > 0
							ZZH->ZZH_MKMNF	:= Val(aSepLin[4])
						EndIf
						If Val(aSepLin[5]) > 0
							ZZH->ZZH_MKNMNF	:= Val(aSepLin[5])
						EndIf
						If Val(aSepLin[6]) > 0
							ZZH->ZZH_INDICE	:= Val(aSepLin[6])
						EndIf
						ZZH->(MsUnlock())

					EndIf

					ZZH->(DbSkip())

				EndDo
			EndIf
		EndIf

		//Proxima linha
		FT_FSKIP()

	Enddo

	//Fechar Arquivo
	FT_FUSE()

	ApMsgInfo("Importado com sucesso")

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AN007
Incluir Nova Linha e Marca
@author felipe.caiado
@since 13/03/2019
@version undefined
@type function
/*/
//-------------------------------------------------------------------

Static Function AN007()

	Local oModel     	:= FWModelActive()
	Local oView			:= FwViewActive()
	Local oZZH1Mod  	:= oModel:GetModel( 'ZZHDETAIL1' )
	Local oZZH2Mod  	:= oModel:GetModel( 'ZZHDETAIL2' )

	//Insere linha no primeiro grid
	oZZH1Mod:SetNoInsertLine(.F.)

	oZZH1Mod:AddLine()

	oZZH1Mod:SetNoInsertLine(.T.)

	lUpdCNF := oZZH1Mod:CanUpdateLine()

	If !lUpdCNF
		oZZH1Mod:SetNoUpdateLine(.F.)
	EndIf

	oZZH1Mod:SetNoDeleteLine(.F.)

	oZZH1Mod:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})

	oZZH1Mod:GoLine(oZZH1Mod:GetLine())

	aPerg	:= {}
	aRet 	:= {}

	aAdd( aPerg ,{1,Alltrim("Marca"),Space(05),"@!",".T.","",".T.",30,.T.})
	aAdd( aPerg ,{1,Alltrim("Linha"),Space(05),"@!",".T.","",".T.",30,.T.})
	aAdd( aPerg ,{1,Alltrim("Nome"),Space(40),"@!",".T.","",".T.",100,.T.})
	aAdd( aPerg ,{1,Alltrim("Marca Herança"),Space(05),"@!",".T.","",".T.",30,.F.})
	aAdd( aPerg ,{1,Alltrim("Linha Herança"),Space(05),"@!",".T.","",".T.",30,.F.})

	//Mostra tela de Parâmetros
	If !ParamBox(aPerg ,"Atualização de Markup",@aRet)
		Return()
	EndIf

	oZZH1Mod:SetValue( 'ZZH_MARCA',MV_PAR01 )
	oZZH1Mod:SetValue( 'ZZH_GRUPO',MV_PAR02 )
	oZZH1Mod:SetValue( 'ZZH_NREDUZ',MV_PAR03 )

	oView:Refresh('VIEW_ZZH1')

	//Limpa o Grid
	oZZH2Mod:ClearData(.F.,.T.)

	//Dados do SM0
	aSM0 := FWLoadSM0(.T.)

	nLinhaZZH := 1

	If !Empty(MV_PAR04)
		DbSelectArea("ZZH")
		ZZH->(DbSetOrder(1))//ZZH_FILIAL+ZZH_MARCA+ZZH_GRUPO+ZZH_FILAN
		If ZZH->(DbSeek(xFilial("ZZH")+MV_PAR04+MV_PAR05))
			While !ZZH->(Eof()) .And. xFilial("ZZH")+MV_PAR04+MV_PAR05 == ZZH_FILIAL+ZZH_MARCA+ZZH_GRUPO

				oZZH2Mod:SetNoInsertLine(.F.)

				If nLinhaZZH > 1
					If oZZH2Mod:AddLine() <> nLinhaZZH
						Help( ,, 'HELP',, 'Nao incluiu linha SB1' + CRLF + oModel:getErrorMessage()[6], 1, 0)
						Loop
					EndIf
				EndIf

				oZZH2Mod:SetNoInsertLine(.T.)

				lUpdCNF := oZZH2Mod:CanUpdateLine()

				If !lUpdCNF
					oZZH2Mod:SetNoUpdateLine(.F.)
				EndIf

				oZZH2Mod:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})

				oZZH2Mod:SetValue( 'ZZH_FILAN',ZZH->ZZH_FILAN )
				oZZH2Mod:SetValue( 'ZZH_MKMNF',ZZH->ZZH_MKMNF )
				oZZH2Mod:SetValue( 'ZZH_MKNMNF',ZZH->ZZH_MKNMNF )
				oZZH2Mod:SetValue( 'ZZH_INDICE',ZZH->ZZH_INDICE )

				oZZH2Mod:GetStruct():SetProperty('ZZH_FILAN',MODEL_FIELD_WHEN,{||.F.})

				//oZZH2Mod:SetNoUpdateLine(!lUpdCNF)

				nLinhaZZH++

				ZZH->(DbSkip())

			EndDo

		EndIf
	Else

		For nX:= 1 To Len(aSM0)

			If Substr(aSM0[nX][SM0_FILIAL],1,2) <> "02"
				Loop
			EndIF

			oZZH2Mod:SetNoInsertLine(.F.)

			If nLinhaZZH > 1
				If oZZH2Mod:AddLine() <> nLinhaZZH
					Help( ,, 'HELP',, 'Nao incluiu linha SB1' + CRLF + oModel:getErrorMessage()[6], 1, 0)
					Loop
				EndIf
			EndIf

			oZZH2Mod:SetNoInsertLine(.T.)

			lUpdCNF := oZZH2Mod:CanUpdateLine()

			If !lUpdCNF
				oZZH2Mod:SetNoUpdateLine(.F.)
			EndIf

			oZZH2Mod:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})

			oZZH2Mod:SetValue( 'ZZH_FILAN',aSM0[nX][SM0_FILIAL] )
			oZZH2Mod:SetValue( 'ZZH_MKMNF',0 )
			oZZH2Mod:SetValue( 'ZZH_MKNMNF',0 )
			oZZH2Mod:SetValue( 'ZZH_INDICE',0 )

			oZZH2Mod:GetStruct():SetProperty('ZZH_FILAN',MODEL_FIELD_WHEN,{||.F.})

			//oZZH2Mod:SetNoUpdateLine(!lUpdCNF)

			nLinhaZZH++

		Next nX

	Endif

	oZZH2Mod:GoLine(1)

	oView:Refresh('VIEW_ZZH2')

	oView:GetViewObj("VIEW_ZZH2")[3]:oBrowse:oBrowse:SetFocus()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AN008
Salvar Dados
@author felipe.caiado
@since 13/03/2019
@version undefined
@type function
/*/
//-------------------------------------------------------------------

Static Function AN008()

	Local oModel     	:= FWModelActive()
	Local oView			:= FwViewActive()
	Local oZZH1Mod  	:= oModel:GetModel( 'ZZHDETAIL1' )
	Local oZZH2Mod  	:= oModel:GetModel( 'ZZHDETAIL2' )

	Begin Transaction

		If !Empty(oZZH1Mod:GetValue("ZZH_GRUPO"))

			Reclock("ZZ8",.T.)
			ZZ8->ZZ8_FILIAL	:= xFilial("ZZ8")
			ZZ8->ZZ8_LINHA	:= oZZH1Mod:GetValue("ZZH_GRUPO")
			ZZ8->ZZ8_DESCRI	:= oZZH1Mod:GetValue("ZZH_NREDUZ")
			SZ8->(MsUnlock())

			Reclock("ZZN",.T.)
			ZZN->ZZN_FILIAL := xFilial("ZZN")
			ZZN->ZZN_COD 	:= oZZH1Mod:GetValue("ZZH_MARCA")
			ZZN->ZZN_DESCRI := ""
			ZZN->ZZN_LINHA 	:= oZZH1Mod:GetValue("ZZH_GRUPO")
			ZZN->ZZN_DESLIN := oZZH1Mod:GetValue("ZZH_NREDUZ")
			ZZN->(MsUnlock())

		EndIf

		For nY := 1 to oZZH2Mod:Length()

			oZZH2Mod:GoLine(nY)

			Reclock("ZZH",.T.)
			ZZH->ZZH_FILIAL := xFilial("ZZH")
			ZZH->ZZH_MARCA 	:= oZZH1Mod:GetValue("ZZH_MARCA")
			ZZH->ZZH_GRUPO 	:= oZZH1Mod:GetValue("ZZH_GRUPO")
			ZZH->ZZH_NREDUZ := ""
			ZZH->ZZH_FILAN 	:= oZZH2Mod:GetValue("ZZH_FILAN")
			ZZH->ZZH_MKMNF 	:= oZZH2Mod:GetValue("ZZH_MKMNF")
			ZZH->ZZH_MKNMNF := oZZH2Mod:GetValue("ZZH_MKNMNF")
			ZZH->ZZH_INDICE := oZZH2Mod:GetValue("ZZH_INDICE")
			ZZH->(MsUnlock())

		Next nY

	End Transaction

	oView:GetViewObj("VIEW_ZZH1")[3]:oBrowse:oBrowse:SetFocus()

	FwMsgRun(Nil,{||AN009() },Nil,"Aguarde, Atualizando...")

	ApMsgInfo("Salvo com sucesso")

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AN009
Carga na grid de Fornecedor
@author felipe.caiado
@since 26/03/2019
@version 1.0
@param oGridModel, object, Modelo
@param lCopy, logical, Copia?
@type function
/*/
//-------------------------------------------------------------------
Static Function AN009()

	Local cAliasZZH	as character
	Local cNome		as character
	Local oModel     	:= FWModelActive()
	Local oView			:= FwViewActive()
	Local oZZH1Mod  	:= oModel:GetModel( 'ZZHDETAIL1' )
	Local oZZH2Mod  	:= oModel:GetModel( 'ZZHDETAIL2' )
	Local nLinhaZZH		:= 1

	cAliasZZH 	:= GetNextAlias()
	cNome 		:= ""

	BeginSQL alias cAliasZZH
		SELECT
		ZZH_MARCA,
		ZZH_GRUPO
		FROM
		%table:ZZH% ZZH
		WHERE
		ZZH_FILIAL = %exp:xFilial("ZZH")%
		AND ZZH.%notDel%
		GROUP BY
		ZZH_MARCA,
		ZZH_GRUPO
		ORDER BY
		ZZH_MARCA,
		ZZH_GRUPO
	EndSql

	oZZH1Mod:ClearData(.F.,.T.)

	While !(cAliasZZH)->(Eof())

		oZZH1Mod:SetNoInsertLine(.F.)

		If nLinhaZZH > 1
			If oZZH1Mod:AddLine() <> nLinhaZZH
				Help( ,, 'HELP',, 'Nao incluiu linha SB1' + CRLF + oModel:getErrorMessage()[6], 1, 0)
				Loop
			EndIf
		EndIf

		oZZH1Mod:SetNoInsertLine(.T.)

		lUpdCNF := oZZH1Mod:CanUpdateLine()

		If !lUpdCNF
			oZZH1Mod:SetNoUpdateLine(.F.)
		EndIf

		oZZH1Mod:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})

		//Nome do Fornecedor ou Linha
		If Empty((cAliasZZH)->ZZH_GRUPO)
			DbSelectArea("ZZM")
			ZZM->(DbSetOrder(2))//ZZM_FILIAL+ZZM_CODMAR
			If ZZM->(DbSeek(xFilial("ZZM")+(cAliasZZH)->ZZH_MARCA))

				DbSelectArea("SA2")
				SA2->(DbSetOrder(1))//A2_FILIAL+A2_FORNECE+A2_LOJA
				If SA2->(DbSeek(xFilial("SA2")+ZZM->ZZM_FORNEC+ZZM->ZZM_LOJA))
					cNome := SA2->A2_NOME
				Else
					cNome := ""
				EndIf

			Else

				cNome := ""

			EndIf
		Else

			DbSelectArea("ZZ8")
			ZZ8->(DbSetOrder(1))//ZZ8_FILIAL+ZZ8_LINHA
			If ZZ8->(DbSeek(xFilial("ZZ8")+(cAliasZZH)->ZZH_GRUPO))
				cNome := ZZ8->ZZ8_DESCRI
			Else
				cNome := ""
			EndIf

		EndIf

		oZZH1Mod:SetValue( 'ZZH_MARCA',(cAliasZZH)->ZZH_MARCA )
		oZZH1Mod:SetValue( 'ZZH_GRUPO',(cAliasZZH)->ZZH_GRUPO )
		oZZH1Mod:SetValue( 'ZZH_NREDUZ',cNome )

		oZZH1Mod:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.F.})

		oZZH1Mod:SetNoUpdateLine(!lUpdCNF)

		nLinhaZZH++

		(cAliasZZH)->(DbSkip())

	EndDo

	(cAliasZZH)->( DbCloseArea() )

	oZZH1Mod:GoLine(1)

	oView:Refresh('VIEW_ZZH1')

Return()
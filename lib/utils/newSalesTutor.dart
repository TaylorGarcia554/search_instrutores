import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> targets = [];

void initTargets(
  GlobalKey keyDataPedido,
  GlobalKey keyDataEntrega,
  GlobalKey keyTipoEntrega,
  GlobalKey keyPedido,
  GlobalKey keyValor,
  GlobalKey keyTipoPagamento,
  GlobalKey keyValorCorreios,
  GlobalKey keyCliente,
  GlobalKey keyProduto,
) {
  targets = [
    TargetFocus(
      keyTarget: keyDataPedido,
      shape: ShapeLightFocus.RRect, // Circle ou RRect
      radius: 40, // tamanho do círculo
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cadastrar Nova Venda",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Aqui você seleciona a data do pedido. Ela já vem pre-selecionada, então não precisa mexer se não quiser. \n\nClique na data para seguir com o tutorial.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        )
      ],
    ),
    TargetFocus(
      keyTarget: keyDataEntrega,
      shape: ShapeLightFocus.RRect, // Circle ou RRect
      radius: 40, // tamanho do círculo
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cadastrar Nova Venda",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Aqui voce só marca se já foi entregue o material/combo. Se não tiver sido entregue, deixe em branco. \n\nClique na data para seguir com o tutorial.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        )
      ],
    ),
    TargetFocus(
      keyTarget: keyTipoEntrega,
      shape: ShapeLightFocus.RRect, // Circle ou RRect
      radius: 40, // tamanho do círculo
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cadastrar Nova Venda",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Aqui voce preenche com \"Link\" se a entrega for Via Link. Se for pelos Correios, preencher com o código dos correios. \n\nSe por acaso não tiver o código ainda, deixar em branco. \n\nClique na caixa para seguir com o tutorial.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        )
      ],
    ),
    TargetFocus(
      keyTarget: keyPedido,
      shape: ShapeLightFocus.RRect, // Circle ou RRect
      radius: 40, // tamanho do círculo
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cadastrar Nova Venda",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Aqui voce preenche com o Tipo do Pedido, se foi Direto ( conversado com as atendentes ) ou se foi pela Loja. Se foi pela loja, colocar o Código da Venda aqui. \n\nClique na caixa para seguir com o tutorial.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        )
      ],
    ),
    TargetFocus(
      keyTarget: keyValor,
      shape: ShapeLightFocus.RRect, // Circle ou RRect
      radius: 40, // tamanho do círculo
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cadastrar Nova Venda",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Aqui voce preenche com o valor da Venda. \n\nClique na caixa para seguir com o tutorial.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        )
      ],
    ),
    TargetFocus(
      keyTarget: keyTipoPagamento,
      shape: ShapeLightFocus.RRect, // Circle ou RRect
      radius: 40, // tamanho do círculo
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cadastrar Nova Venda",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Aqui voce preenche com a forma que o Cliente pagou, se foi pela ContaPJ, pelo PagSeguro, PagaLeve e outros. \n\nClique na caixa para seguir com o tutorial.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        )
      ],
    ),
    TargetFocus(
      keyTarget: keyValorCorreios,
      shape: ShapeLightFocus.RRect, // Circle ou RRect
      radius: 40, // tamanho do círculo
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cadastrar Nova Venda",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Aqui voce preenche com o valor que ficou o frete. Geralmente voces não vao saber, então deixe em branco. \n\nClique na caixa para seguir com o tutorial.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        )
      ],
    ),
    TargetFocus(
      keyTarget: keyCliente,
      shape: ShapeLightFocus.RRect, // Circle ou RRect
      radius: 40, // tamanho do círculo
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cadastrar Nova Venda",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Aqui voce preenche com o Email, Nome, CPF/CNPJ e Telefone ( sendo o telefone o mais dificil ) e vai aparecer o resultado em baixo. \n\nClique na caixa para seguir com o tutorial.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        )
      ],
    ),
    TargetFocus(
      keyTarget: keyProduto,
      shape: ShapeLightFocus.RRect, // Circle ou RRect
      radius: 40, // tamanho do círculo
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cadastrar Nova Venda",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Aqui voce preenche com o Produto que o Cliente adquiriu. \n\nClique na caixa para seguir com o tutorial.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        )
      ],
    ),
  ];
}

void showTutorial(BuildContext context) {
  TutorialCoachMark(
    targets: targets,
    colorShadow: Colors.black.withAlpha(180),
    paddingFocus: 10,
    textSkip: "Pular",
    hideSkip: false,
  ).show(context: context);
}

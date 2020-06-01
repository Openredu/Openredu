[![Build Status](https://travis-ci.org/Openredu/Openredu.svg?branch=master)](https://travis-ci.org/Openredu/Openredu)

## OpenRedu Core

Este repositório contem o core do OpenRedu. O openredu-core é a parte central da plataforma social educacional OpenRedu. Também existem alguns subsistemas/serviços que estão em servidores/projetos/repositórios diferentes. A saber:

- [Portal de aplicativos](http://github.com/redu/apps): Marketplace de aplicativos educacionais.
- [Visualizações semânticas](http://github.com/redu/vis): Armazenamento e construção de visualizações semânticas do Redu.
- [Central de Ajuda](http://github.com/OpenRedu/help-center): [Tutoriais](http://ajuda.openredu.com) de suporte no uso da plataforma.
- [Página de desenvolvedores](http://github.com/redu/redu.github.com): Documentação da API REST do Redu
- [Página do livro](http://github.com/redu/livro): Pagina do livro [Educar com o Redu](http://educarcom.redu.com.br)
- [Redu Mobile](http://github.com/redu/mobile): Aplicativo Android oficial.
- [Wally Server](http://github.com/redu/wally): Mural do Redu (server-side)
- [Wally.js](http://github.com/redu/wally.js): Mural do Redu (client-side)
- [Untied](http://github.com/redu/untied): Message Bus utilizado na comunicação entre serviços.
- [Permit](http://github.com/redu/permit): Autorização e gerênciamento de políticas de acesso entre serviços.
- [ReduPy](http://github.com/redu/redupy): Encapsulador Python para a API REST do Redu.
- [JRedu](http://github.com/redu/jredu): Encapsulador Java para a API REST do Redu

### Setup
[Setup Ubuntu](https://github.com/OpenRedu/OpenRedu/wiki/OpenRedu-Setup-%28Ubuntu%29)
[Setup Windows/Mac OS/Ubuntu (Deprecated)](https://github.com/OpenRedu/OpenRedu/wiki/Redu-Setup----Deprecated)


#### Dependências

Para fazer o OpenRedu funcionar em ambiente de desenvolvimento você precisará instalar as seguintes dependências:

- MySQL 5.1
- MongoDB 2.0.6
- Solr 1.4.0

### Coding style

O estilo e padrões de código utilizados estão disponíveis [neste](https://github.com/OpenRedu/OpenRedu/wiki/Coding-Patterns) guia. Leia com atenção antes de submeter patches.

### Contribuições

#### Pull requests

Os passos para contribuir com a evolução do código, seja para resolução de issue ou criação de features são os seguintes:

1. Criar um branch novo
2. Realizar mudanças ou adicionar a feature
3. Commitar mudanças e enviá-las para o remoto
4. Realizar pull request e atribuir a um revisor
5. Caso existam revisões: realizar novos commits no mesmo branch criado e enviar para o remoto

Um exemplo de resolução de issue seguiria o seguinte fluxo:

Assumindo que o issue tenha o ID 1300.

```sh
$ redu (master) > git pull origin master
$ redu (master) > git checkout -b issue-1300
$ redu (issue-1300) > git commit -a -m "Minhas modificações"
$ redu (issue-1300) > git push origin issue-1300
```

Para mais informações sobre como fazer o pull request, consulte [este](https://help.github.com/articles/using-pull-requests) post.

#### Reportando issues da API

O primeiro passo é decidir em qual repositório criar o issue:

- Para bugs na API HTTP propriamente dita: https://github.com/OpenRedu/OpenRedu/issues
- Para bugs na documentação: https://github.com/OpenRedu/redu.github.com

Para problemas na API REST, É importante expressar os problemas em termos de HTTP e não da linguagem utilizada. Por exemplo, ao invés de dizer que o método ``getUsers()`` está lançando null pointer, tentem explicar que uma requisição do tipo GET para ``/api/spaces/1/users`` está retornando o código 500. Fica mais fácil de investigar dessa forma.

### DelayedJob

O [DelayedJob](https://github.com/collectiveidea/delayed_job) é utilizado como infraestrutura para processamento de tarefas em background.

```

#### Responsabilidades de cada worker do Delayed Job

- `delayed_job.0` (general): Execução de tarefas gerais como criação de associações entre usuários e postagens no mural (não há necessidade de serem executadas imediatamente).
- `delayed_job.1` (email): Envio de emails.
- `delayed_job.2` (vis): Envio de dados para Vis (requisições HTTP).
- `delayed_job.3` (hierarchy-associations): Criação de associações da hierarquia que precisam ser feitas o quanto antes.

### Serviço de entrega de e-mails

Para utilizar entrega em segundo plano, é necessário chamar o método do ActionMailer da seguinte forma: ``object.delay(:queue => 'email').method``. Onde ``method`` é tipo de notificação que deve ser gerada. Por exemplo, para enviar o e-mail de convite, a chamada seria a seguinte:

```ruby
UserNotifier.delay(:queue => 'email').external_user_course_invitation(user_course_invitation, course)
```

É importante notar que e-mails devem ser enfileirados na fila ``email`` para evitar que o envio dos mesmos afetem a vazão do processamento de outros Jobs. Para cada e-mail será enfileirado um Job do DelayedJob que lidará com a renderização da View e entrega para a Amazon SES.


Para mais informações de uso: ``bundle exec ar_sendmail_rails3 -h``

# Licença Utilizada

O pacote global de software Redu tem direitos reservados para vários autores registrado junto ao INPI. Ele é um Software Livre e de Código Aberto e tudo isso é fornecido sob os termos da licença [GNU General Public License versão 2](http://www.gnu.org/licenses/gpl-2.0.html) publicada pela [Free Software Foundation](http://www.fsf.org/).

Redu e a documentação do Redu são distribuídos na esperança de que eles vão ser útil, mas SEM NENHUMA GARANTIA; sem mesmo a garantia implícita de COMERCIALIZAÇÃO ou ADEQUAÇÃO A UM DETERMINADO FIM. Consulte a Licença Pública Geral GNU [aqui] para mais detalhes.

[aqui]: https://github.com/OpenRedu/OpenRedu/blob/master/LICENSE

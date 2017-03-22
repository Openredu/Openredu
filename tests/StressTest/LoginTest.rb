require 'rubygems'
require 'ruby-jmeter'

#Este teste tenta logar varios usuarios de uma vez so, note que neste teste eh utilizado apenas um unico usuario (miguel), num teste real o ideal seria criar multiplos usuarios, armazenar num CSV e utiliza-lo para fazer o teste.

#URL do servidor, com porta
url = 'http://localhost:3000',
#Login do usuário
user_session_login = 'miguel',
#Senha do usuario
user_session_password = '23021992',
#Numero base de threads que serao utilizadas
count = 1000



def generate_report(url, user_session_login, user_session_password, count)
    #Criacao do objeto URI que sera utilizado para retirar informacoes de acesso ao servidor
    uri = URI('http://localhost:3000')
    domain, port = uri.host, uri.port
    #test eh a palavra do jmeter para informar que o teste eh iniciado naquele ponto
    test do
        #sao inicializadas x threads, onde x == count. Cada uma dessas threads tentara logar como um usuario,
        # testando assim a capacidade do servidor
        threads count: count do
            defaults domain: domain, port: port
            cookies policy: 'rfc2109', clear_each_iteration: true
            
            #A transacao ou eh completada, ou falha
            transaction 'dashboard_pages' do
                visit name: '/', url: '/' do
                    #Eh necessario verificar os tokens csrf da pagina para permitir que o servidor reconhece
                    #as requisicoes de login
                    extract name: 'csrf-token', xpath: "//meta[@name='csrf-token']/@content", tolerant: true
                    extract name: 'csrf-param', xpath: "//meta[@name='csrf-param']/@content", tolerant: true
                end
                
                http_header_manager name: 'X-CSRF-Token', value: '${csrf-token}'
                
                #Da um submit no form com os dados passados inicialmente, note que caso haja um erro em qualquer
                #momento, os mesmo serao reportados nos resultados de View Results Tree para serem identificados
                submit name: '/sessions', url: '/sessions',
                fill_in: {
                    '${csrf-param}' => '${csrf-param}',
                    'user_session[login]' => user_session_login,
                    'user_session[password]' => user_session_password,
                }
            
            end
            #Quais resultados deverao ser gerados por esse teste
            view_results_tree
            summary_report
        end
        #Em .jmx eh possivel acrescentar o path que o arquivo de teste sera criado no formato:
        # (file: "/tmp/my_testplan.jmx")
    end.jmx
end

generate_report(url, user_session_login, user_session_password, count)
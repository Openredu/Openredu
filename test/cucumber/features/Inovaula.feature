#language: en
Feature: Integração do sistema Openredu e Inovaula Steps
    As a Usuário do Openredu
    I want to poder associar os conteúdos da disciplina que estou estudando no OpenRedu à 
    conteúdos de mesma área presentes no Inovaula 
    So that poder linkar esses conteúdos relacionados a uma disciplina.
  
    Scenario: Remoção de links sem estar logado como administrador da disciplina
        Given Eu não estou logado como “Administrador”
        When eu clico na opção de configurações da disciplina no OpenRedu
        Then é exibida uma mensagem de erro “Você não tem as permissões necessárias para realizar esta ação”
  
    Scenario:  Clicar na opção “Conteúdos”
        Given  Estou na pagina da disciplina “Grandezas e Unidades”
        When eu clico na opção “Conteúdos auxiliares”
        Then Uma nova guia é aberta no navegador
        And é exibida a pagina de conteúdos do inovaula relacionados a disciplina.
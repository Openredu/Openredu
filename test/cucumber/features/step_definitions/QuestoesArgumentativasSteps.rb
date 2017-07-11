# encoding: UTF-8
require 'minitest/unit'
include MiniTest::Assertions
require pages.QuestionsPage.*
require pages.

Given(/^que não existe uma questão argumentativa com enunciado "([^"]*)"  e com assunto "([^"]*)" no sistema$/) do |arg1, arg2|
  #assert questaoNoExist(arg1, arg2)
  assert(questaoNoExist(arg1, arg2), "Não existe uma  questão com esse enunciado nem com esse assunto assunto")

end

When(/^eu crio uma questão argumentativa com enunciado "([^"]*)" e com assunto "([^"]*)"$/) do |arg1, arg2|
  @questao = Questao.new(arg1, arg2)
  @questao.save()

end

Then(/^salve no sistema a nova questão argumentativa com enunciado "([^"]*)" e com assunto "([^"]*)" $/) do
  assert((not questaoNoExist(arg1, arg2)), "Existe uma questão com esse enunciado nem com esse assunto assunto")
end


Given(/^que estou no menu de questões$/) do
  addPage()
end

When(/^eu seleciono a opção "([^"]*)" no menu de questões$/) do |arg1|
  selectQuestionsArgumentativeInQuestionPage(arg1)
end

When(/^eu seleciono nova questão argumentativa na página de questões$/) do
  createQuestionArgumentative()
end

Then(/^eu posso ver os detalhes da questão argumentativa$/) do
  mostrarDetalhes()
end



class Questao
    attr_reader :enunciado
    attr_reader :assunto

    def initialize (enunciado, assunto)
        @enunciado = enunciado
        @assunto = assunto
    end

    def destroy
      #self.destroy
    end

    def self.save
      self.should save()

    end
end



def addPage
  Login()
  at QuestionsPage
end

def questaoNoExist(enunciado, assunto)
  return Questao.should find_by_enunciado_and_assunto(enunciado, assunto) == nil
end

def selectQuestionsArgumentativeInQuestionPage(arg1)
  selectQuestionArgumentative(arg1)
  at QuestionCreatePage
end

def createQuestionArgumentative
  createQuestions()
end

def mostrarDetalhes
  fillQuestionDetails()
end
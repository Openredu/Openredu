class QuestionsPage
    static url = "periodico/list"


    static at = {

    }

    static content = {
    }

    def selectQuestionArgumentative(arg1)
        $('a.select.arg1').click()
    end


end

class QuestionsCreatePage
    static url = "periodico/list"


    static at = {

    }

    static content = {
    }

    def createQuestions
        $('a.create').click()
    end

    def fillArticleDetails
        $("form").enunciado = "Quem foi Romulo e Remulo?"
        $("form").assunto = "Historia"
    end



end
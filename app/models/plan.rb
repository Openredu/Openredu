# -*- encoding : utf-8 -*-
class Plan < ActiveRecord::Base
  include AASM

  serialize :billable_audit

  belongs_to :billable, :polymorphic => true
  belongs_to :user

  scope :blocked, where(:state => "blocked")
  # Necessário, pois em produção o scope gerado automaticamente estava
  # fazendo cache de consultas anteriores
  scope :current, where(:current => true)

  validates_presence_of :user

  attr_protected :state, :billable_audit

  aasm_column :state
  aasm_initial_state :active

  aasm_state :active
  aasm_state :blocked, :enter => [:send_blocked_notice]
  aasm_state :migrated

  aasm_event :block do
    transitions :to => :blocked, :from => [:active]
  end

  aasm_event :activate do
    transitions :to => :active, :from => [:blocked, :active]
  end

  aasm_event :migrate do
    transitions :to => :migrated, :from => [:active]
  end

  def self.from_preset(key, type="PackagePlan")
    plan = begin
             type.constantize.new
           rescue NameError
             PackagePlan.new
           end
    klass = plan.class
    plan.attributes = klass::PLANS.fetch(key, klass::PLANS[:free])
    plan
  end

  # Serializa billable associado e salva com propósito de auditoria
  def audit_billable!
    options = Hash.new
    options[:include] = [:courses] if self.billable.is_a? Environment
    self.billable_audit = self.billable.serializable_hash(options)
    self.save!
  end

  # Realiza setup necessário à migração
  def setup_for_migration
    nil # Deve ser implementado nos planos que necessitam de setup
  end

  # Efetua a migração para o plano passado como parâmetro
  # - Faz o tratamento correto para o invoice atual
  #   . Se estiver aberto ou pendente, a data final é atualizada, ele é
  #     fechado e o valor repassado como adição para o novo invoice
  #   . Se estiver pago, permanecerá pago e o desconto é repassado para o
  #     novo invoice
  # - Cria um novo invoice com o valor relativo a quantidade de dias
  #   e com desconto (caso houver) do invoice anterior
  def migrate_to(new_plan)
    new_plan.user = self.user
    self.billable.plan = new_plan
    new_plan.setup_for_migration
    self.migrate!
  end

  def send_blocked_notice
    UserNotifier.delay(:queue => 'email').blocked_notice(self.user, self)
  end

  # Bloqueia o acesso ao billable e todos os seus filhos na hierarquia
  # Utilizado apenas diretamente no console
  def block_all_access!
    if self.billable.is_a? Environment
      environment = self.billable
      courses = self.billable.courses.includes(:spaces =>
                                               [:subjects => :lectures])
      spaces = courses.collect(&:spaces).flatten

      Environment.update_all(["blocked = ?", true], ["id = ?", self.billable])
    else
      courses = [self.billable]
      spaces = courses[0].spaces.includes(:subjects => :lectures)
    end
    subjects = spaces.collect(&:subjects).flatten
    lectures = subjects.collect(&:lectures).flatten

    Course.update_all(["blocked = ?", true], ["id IN (?)", courses])
    Space.update_all(["blocked = ?", true], ["id IN (?)", spaces])
    Subject.update_all(["blocked = ?", true], ["id IN (?)", subjects])
    Lecture.update_all(["blocked = ?", true], ["id IN (?)", lectures])
  end
end

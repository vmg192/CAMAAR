module ApplicationHelper
  # Adicionamos o argumento 'active_condition: false'
  def menu_button_classes(path, active_condition: false)
    base_classes = "flex items-center justify-center w-[257px] h-[46px] font-roboto py-[11px] px-[50px] border-b border-transparent shadow-lg rounded cursor-pointer gap-[10px] opacity-100 no-underline"

    active_style = "bg-project-purple text-white hover:bg-project-purple-dark"
    inactive_style = "bg-white text-black hover:bg-gray-100"

    # O botão fica roxo se: for a página exata OU a condição extra for verdadeira
    if current_page?(path) || active_condition
      "#{base_classes} #{active_style}"
    else
      "#{base_classes} #{inactive_style}"
    end
  end
end

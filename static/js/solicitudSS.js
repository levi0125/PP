let cont_monto=document.getElementById("contenedor-monto")
let inputs= document.querySelectorAll("input,select,textarea")

function eventosCampos(){
    inputs.forEach(input=>{
        if(input.parentNode.classList.contains("desplazamiento")){
            input.parentNode.addEventListener("click",(e,target=e.target)=>{
                console.log(target)
                if(target.matches("label")){
                    target.classList.add("desplazado")
                    const input = target.parentNode.querySelector("input, select");
                    input?.focus(); // El ?. evita error si no existe
                }
            })
            input.addEventListener("blur",(e,target=e.target)=>{
                console.log("perdió foco")
                if(!target.matches("label") 
                    && target.value==""){
                    target.parentNode.children[0].classList.remove("desplazado")
                }
            })
            desplazarCampo(input)
            input.addEventListener("focus",(e,target=e.target)=>{
                desplazarCampo(target,true)
            })
        }    
        input.addEventListener("change",e=>{
            if(e.target.value!=""){
                e.target.setCustomValidity("")
            }
        })
        
    })
}

function desplazarCampo(target,esfocus=false){
    if(!target.parentNode.classList.contains("desplazamiento")){
        return 
    }
    let label=target.parentNode.children[0]
    if( (target.value=="" && esfocus)  
        || ( !esfocus && target.value!="" && !label.classList.contains("desplazado"))){
        label.classList.add("desplazado")
    }
}

function observador(){
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add("visible");
                // Opcional: detener la observación para que no se repita
                observer.unobserve(entry.target);
            }
        });
    });
    
    document.querySelectorAll(".scroll-reveal").forEach(el => observer.observe(el));
    
}
function validarInputs(){
    console.log("VAlidar INPUTS")
    for(input of inputs){
        if(input.checkVisibility()){
            if(input.value==""){
                console.log("EROOR:",input,input.value)
                input.focus()
                input.setCustomValidity("Debes llenar el campo")
                return false
            }
            if(!input.checkValidity()){
                input.setCustomValidity("El formato es incorrecto")
                return false
            }
            console.log("deberia ser true")
        }
    }
    return true
}
async function obtenerDatosDeInstitucion(rfc){
    return await fetch("/institucion:"+rfc).then(response => {
        if (!response.ok) {
        throw new Error(`Error HTTP: ${response.status}`);
        }
        return response.json(); // convierte la respuesta a JSON
    })
    .then(data => {
        console.log('Datos recibidos:', data); // aquí trabajas con el JSON
        return data;
    })
    .catch(error => {
        console.error('Error en la solicitud:', error);
    });
}
function llenarCampo(input,valor){
    input.value=valor
    desplazarCampo(input)
}
async function llenarInstitucion(rfc){
    let res=await obtenerDatosDeInstitucion(rfc)
    if(res.existe){
        if(confirm("Ya hay registro de esta institucion. ¿Desea que rellenemos los datos?")){
            let campos=document.querySelectorAll(
                "#Institucion,#Persona-objetivo,#Cargo,#Calle-Institucion,#Num-Institucion,#Colonia-Institucion,#CP-Institucion,#Telefono-Institucion")
                
                llenarCampo(campos[0],res.datos.institucion.nombre)
                llenarCampo(campos[1],res.datos.institucion.representante)
                llenarCampo(campos[2],res.datos.institucion.cargo)

                llenarCampo(campos[3],res.datos.domicilio.calle)
                llenarCampo(campos[4],res.datos.domicilio.numero)
                llenarCampo(campos[5],res.datos.domicilio.colonia)
                llenarCampo(campos[6],res.datos.domicilio.cp)
                llenarCampo(campos[7],res.datos.institucion.telefono)
        }
    }
}
function eventosParticulares(){
    document.getElementById("Recibe-apoyo").addEventListener("change",ev=>{
        if(ev.target.value=="SI"){
            cont_monto.classList.remove("desaparecer")
        }else{
            cont_monto.classList.add("desaparecer")
        }
    })
    document.getElementById("No-Control")?.addEventListener("change",e=>{
        let target=e.target

        llenarCampo(document.getElementById("Correo-Institucional"),target.value+"@cetis155.edu.mx")
    })
    document.getElementById("Institucion").addEventListener("change",e=>{
        let nombre=e.target.value
        console.log("nombre:",nombre)
        if(nombre.includes("155")){
            if(confirm("¿Quieres Autocompletar con los datos del cetis 155?") && confirm("¿seguro?")){
                let rfc=document.getElementById("rfc-155").content
                llenarInstitucion(rfc)
                llenarCampo(document.getElementById("RFC"),rfc)
            }
        }
    })
    document.getElementById("RFC").addEventListener("change",async e=>llenarInstitucion(e.target))

}
function eventoForm(){
    document.querySelector("form").addEventListener("submit",e=>{
        // e.preventDefault()
        if(!validarInputs()){
            e.preventDefault()
            return
        }
        let date=document.getElementById("Inicio").value.split("-")
        let meses="Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre".split(",")
        let enviar=confirm(`Su solicitud empieza el ${date[2]} de ${meses[ parseInt(date[1])-1] } del ${date[0]}.¿Esta bien?`)

        if(!enviar){
            e.preventDefault()
            return;
        }
    })
}
function eventosSelect(){
    document.querySelectorAll("select").forEach(select=>{
        let value=select.dataset.value
        if(value){
            llenarCampo(select,value)
        }
    })
}

eventosCampos()
observador()
eventosParticulares()
eventoForm()
eventosSelect()
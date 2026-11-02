import type { Metadata } from 'next';
import './style.css';
export const metadata:Metadata={title:'Klunder Digital Studio | Desarrollo Web, Apps y Software',description:'Arquitectura digital, aplicaciones móviles, plataformas web y software personalizado. Solicita una cotización.'};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="es"><body>{children}</body></html>;}
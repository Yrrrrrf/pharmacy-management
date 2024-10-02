import React from 'react'
import { ShoppingCart, X, Plus, Minus, Pill, Package } from 'lucide-react'
import { Button } from "@/components/ui/button"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Separator } from "@/components/ui/separator"
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet"

type CartItem = {
  id: string
  name: string
  price: number
  quantity: number
  isPharma: boolean
  image: string
}

const cartItems: CartItem[] = [
  { id: '1', name: 'Ibuprofen 400mg', price: 9.99, quantity: 2, isPharma: true, image: '/placeholder.svg?height=80&width=80' },
  { id: '2', name: 'Vitamin C 1000mg', price: 14.99, quantity: 1, isPharma: true, image: '/placeholder.svg?height=80&width=80' },
  { id: '3', name: 'Digital Thermometer', price: 24.99, quantity: 1, isPharma: false, image: '/placeholder.svg?height=80&width=80' },
  { id: '4', name: 'Allergy Relief Tablets', price: 19.99, quantity: 1, isPharma: true, image: '/placeholder.svg?height=80&width=80' },
  { id: '5', name: 'First Aid Kit', price: 29.99, quantity: 1, isPharma: false, image: '/placeholder.svg?height=80&width=80' },
]

export default function CartPreview() {
  const totalItems = cartItems.reduce((sum, item) => sum + item.quantity, 0)
  const subtotal = cartItems.reduce((sum, item) => sum + item.price * item.quantity, 0)
  const tax = subtotal * 0.1 // Assuming 10% tax
  const total = subtotal + tax

  return (
    <Sheet>
      <SheetTrigger asChild>
        <Button variant="outline" size="icon" className="relative">
          <ShoppingCart className="h-5 w-5" />
          <span className="absolute -top-2 -right-2 bg-primary text-primary-foreground text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center">
            {totalItems}
          </span>
        </Button>
      </SheetTrigger>
      <SheetContent className="w-[400px] sm:w-[540px]">
        <SheetHeader>
          <SheetTitle className="text-2xl font-bold">Your Cart</SheetTitle>
          <SheetDescription>
            Review your items before proceeding to checkout.
          </SheetDescription>
        </SheetHeader>
        <ScrollArea className="h-[65vh] w-full pr-4">
          {cartItems.map((item) => (
            <div key={item.id} className="flex items-center py-4">
              <div className="h-20 w-20 flex-shrink-0 overflow-hidden rounded-md border border-gray-200">
                <img
                  src={item.image}
                  alt={item.name}
                  className="h-full w-full object-cover object-center"
                />
              </div>
              <div className="ml-4 flex flex-1 flex-col">
                <div>
                  <div className="flex justify-between text-base font-medium text-gray-900">
                    <h3>{item.name}</h3>
                    <p className="ml-4">${(item.price * item.quantity).toFixed(2)}</p>
                  </div>
                  <p className="mt-1 text-sm text-gray-500 flex items-center">
                    {item.isPharma ? <Pill className="h-4 w-4 mr-1" /> : <Package className="h-4 w-4 mr-1" />}
                    {item.isPharma ? 'Pharmaceutical' : 'Non-Pharmaceutical'}
                  </p>
                </div>
                <div className="flex flex-1 items-end justify-between text-sm">
                  <div className="flex items-center">
                    <Button variant="outline" size="icon" className="h-8 w-8">
                      <Minus className="h-4 w-4" />
                    </Button>
                    <p className="mx-2 text-gray-500">Qty {item.quantity}</p>
                    <Button variant="outline" size="icon" className="h-8 w-8">
                      <Plus className="h-4 w-4" />
                    </Button>
                  </div>
                  <div className="flex">
                    <Button variant="ghost" size="sm">
                      <X className="h-4 w-4 mr-2" />
                      Remove
                    </Button>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </ScrollArea>
        <div className="mt-4">
          <Separator />
          <div className="flex justify-between py-2">
            <span>Subtotal</span>
            <span>${subtotal.toFixed(2)}</span>
          </div>
          <div className="flex justify-between py-2">
            <span>Tax</span>
            <span>${tax.toFixed(2)}</span>
          </div>
          <Separator />
          <div className="flex justify-between py-2 font-bold">
            <span>Total</span>
            <span>${total.toFixed(2)}</span>
          </div>
          <Button className="w-full mt-4">Proceed to Checkout</Button>
        </div>
      </SheetContent>
    </Sheet>
  )
}